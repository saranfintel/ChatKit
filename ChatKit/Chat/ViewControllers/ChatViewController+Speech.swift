//
//  ChatViewController+Speech.swift
//  ChatKit
//
//  Created by saran on 28/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation
import UIKit
import Speech
import AVKit
import AVFoundation

// MARK: -  extension : SFSpeechRecognizerDelegate Method
extension ChatViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            audioButton.isEnabled = true
        } else {
            audioButton.isEnabled = false
        }
    }
}

extension ChatViewController {
    //MARK:- Glow Animation On MIC button
    // Creates a glow effect in the button by setting its layer shadow properties
    func startGlowWithCGColor (growColor:CGColor) {
        
        audioButton.layer.shadowColor = growColor
        audioButton.layer.shadowRadius = 5.0
        audioButton.layer.shadowOpacity = 1.0
        audioButton.layer.shadowOffset = CGSize.zero
        audioButton.layer.masksToBounds = false
        // Autoreverse, Repeat and allow user interaction.
        UIView.animate(withDuration: 0.6, delay: 0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.autoreverse.rawValue |                                                         UIView.AnimationOptions.curveEaseInOut.rawValue | UIView.AnimationOptions.repeat.rawValue
            | UIView.AnimationOptions.allowUserInteraction.rawValue),
                       animations: { () -> Void in
                        // Make it a 15% bigger
                        self.audioButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (Bool) -> Void in
            // Return to original size
            self.audioButton.layer.shadowRadius = 0.0
            self.audioButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
    }

    // Removes the animation
    func stopGlow () {
        audioButton.layer.shadowRadius = 0.0
        audioButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        audioButton.layer.removeAllAnimations()
        audioButton.layer.masksToBounds = true
        audioButton.layer.shadowPath = nil
    }
    
    
    @objc func microphoneTapped(_ recognizer: UIGestureRecognizer?) {
        self.microphoneStatusChanged(isStart: updatedMicStatus)
        if updatedMicStatus {
            self.startRecordingTimer()
            audioButton.backgroundColor = UIColor.clear
            self.startGlowWithCGColor(growColor: ChatColor.appTheme().cgColor)
            
        } else {
            self.stopRecordingTimer()
            self.stopGlow()
        }
        updatedMicStatus = !updatedMicStatus
    }

    @objc func changeLanguageTapped(_ recognizer: UIGestureRecognizer?) {
        if let countryVC = VCNames.countryVC.controllerObject as? CountryPopViewController {
            countryVC.delegate = self
            countryVC.chatViewModel = chatViewModel
            let sbPopup = CardPopupViewController(contentViewController: countryVC)
            sbPopup.show(onViewController: self)
        }
    }
    
    //MARK:- Voice to Text - Speech Recognizer Methods
    /**
     Initiate SFSpeech Recognizer properties for voice recording
     */
    func initSFSpeechRecognizer() {
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                let VOICEResponse = UserDefaults.standard.value(forKey: "VOICERESPONSE")
                if VOICEResponse == nil {
                    UserDefaults.standard.set("true", forKey: "VOICERESPONSE")
                    UserDefaults.standard.synchronize()
                }
                // Microphone permision check here
                // Todo: right now handled alert - replace to place holder text
                _ = self.microPhonePermissionCheck()
            case .denied:
                isButtonEnabled = true
            //self.showNotEnabledAlert(message: "MicroPhoneDeniedText")
            case .restricted:
                isButtonEnabled = true
            //self.showNotEnabledAlert(message: "MicroPhoneRestrictedText")
            case .notDetermined:
                isButtonEnabled = true
                //self.showNotEnabledAlert(message: "MicroPhoneNotDeterminedText")
            }
            OperationQueue.main.addOperation() {
                self.audioButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    /**
     Micro phone permission check here
     */
    func microPhonePermissionCheck() {
        AVCaptureDevice.requestAccess(for: AVMediaType.audio) { response in
            if response == false {
                //self.showNotEnabledAlert(message: "MicroPhoneMessage".localized())
            }
        }
    }
    
    func microphoneStatusChanged(isStart: Bool) {
        //stop
        if isStart == false {
            if audioEngine.isRunning { audioEngine.stop(); recognitionRequest?.endAudio() }
            audioEngine.inputNode.removeTap(onBus: 0)
            if let runningTimer = timer, runningTimer.isValid {
                runningTimer.invalidate()
            }
        } else  {
            startRecording()
            if let runningTimer = timer, runningTimer.isValid { runningTimer.invalidate() }
            timer = Timer.scheduledTimer(timeInterval: 0.08, target: self, selector: #selector(ChatViewController.refreshAudioView(_:)), userInfo:  nil, repeats: true)
        }
    }
    func startRecording() {
        var language = "en-US"
        if let languageObj = UserDefaults.standard.object(forKey: voiceLanguage) as? String {
            language = languageObj
        }
        let locale = Locale(identifier: language)
        speechRecognizer = SFSpeechRecognizer(locale: locale)!
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask?.finish()
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                self.messageInputBar.inputTextView.text = result?.bestTranscription.formattedString
                
                self.lastString = result?.bestTranscription.formattedString ?? ""
                isFinal = (result?.isFinal)!
                if isFinal {
                    //self.sendMessage(message: self.textView?.text ?? "")
                }
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                //                self.audioButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            //print("audioEngine couldn't start because of an error.")
        }
    }
    
    @objc internal func refreshAudioView(_:Timer) {
        //        let siriWave = timer?.userInfo as? EvaSiriWave
        //        siriWave?.update(withLevel: _normalizedPowerLevel(fromDecibels: 0.1))
    }

}

extension ChatViewController {
    
    func startRecordingTimer() {
        lastString = ""
        createTimerTimer(3)
    }
    func stopRecordingTimer() {
        listenerTimer?.invalidate()
        listenerTimer = nil
    }
    fileprivate func whileRecordingTimer() {
        createTimerTimer(0.6)
    }
    
    func createTimerTimer(_ interval:Double) {
        OperationQueue.main.addOperation({[unowned self] in
            self.listenerTimer?.invalidate()
            self.listenerTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { (_) in
                self.listenerTimer?.invalidate()
                //Stop recogniser when both count are same
                if((self.lastString.count - self.lastStringLength) == 0){
                    self.microphoneTapped(nil)
                }else{
                    self.lastStringLength = self.lastString.count
                    self.whileRecordingTimer()
                }
            }
        })
    }
}
