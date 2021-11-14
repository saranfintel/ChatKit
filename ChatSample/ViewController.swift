//
//  ViewController.swift
//  ChatSample
//
//  Created by saran on 02/05/20.
//  Copyright © 2020 saran. All rights reserved.
//

import UIKit
import ChatKit

class ViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    let colorSchemes: [String] = ["Red", "Green", "Yellow", "Purpule", "Blue"]
    let colors: [String] = ["#EA4335", "#3CAD5F",  "#FFFF33", "#9795F0", "#007AFF"]
    
    var selectedIndex = 0
    var selectedColor = "#EA4335"
    var manager: Manager? = Manager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

     @IBAction func saveButtonClicked(_ sender: Any) {
            selectedColor = colors[selectedIndex]
        }

        @IBAction func launchButtonClicked(_ sender: Any) {
            var parameters: [String: Any] = ["baseURL": "https://stage.evamoney.io/api/"]
            parameters["colorCode"] = selectedColor
            parameters["title"] = "Chat"
            parameters["sessionToken"] = "TjMqMj4yyouD2DhD8QuaKpDSGNhUJS"
            parameters["receiveTitle"] = "KH"
            parameters["senderTitle"] = "KR"
            parameters["fontSize"] = 12.0
            parameters["currencySymbol"] = ""
            manager?.viewController(parameters: parameters, sender: nil, receiver: nil, currentQuestionsDict: [:], languagesDict: self.languaheDict())

        }
    
    func languaheDict() -> [String: Any] {
        let jsonText: [String: Any] = ["payload": [["fullText": "English", "locale": "en-US", "initial": "EN"], ["fullText": "English", "locale": "en-US", "initial": "EN"], ["fullText": "English", "locale": "en-US", "initial": "EN"]]]
        return jsonText
//        [
//            {
//                "fullText": "English",
//                "locale": "en-US",
//                "initial": "EN"
//            },
//            {
//                "fullText": "Hindi",
//                "locale": "hi-IN",
//                "initial": "HI"
//            },
//            {
//                "fullText": "Arabic",
//                "locale": "ar-SA",
//                "initial": "AR"
//            }
//        ]
//        var l: [String: Any] = [:]
//        l[0]["fullText"] = "English"
        
    }

}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colorSchemes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colorSchemes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
    }

}
