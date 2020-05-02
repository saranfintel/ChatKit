//
//  ChatFrameworkLauncher.swift
//  ChatKit
//
//  Created by saran on 20/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation
import UIKit

open class Manager: NSObject {

    public override init() {

    }

    public func viewController(parameters: JSONDictionary, sender: UIImage?, receiver: UIImage?, currentQuestionsDict: JSONDictionary) {
         ChatSession.deleteImages()
         if let senderIcon = sender {
             ChatSession.store(image: senderIcon, forKey: "sender", withStorageType: .fileSystem)
         }
         if let receiverIcon = receiver {
             ChatSession.store(image: receiverIcon, forKey: "receiver", withStorageType: .fileSystem)
         }
         UserDefaults.standard.set(parameters, forKey: "ChatData")
         UserDefaults.standard.synchronize()

         ChatWorkflowManager.sharedManager.performNavigationFor("ChatViewController", navType: NavType.model)
         let questionsList: [Questions] = (currentQuestionsDict <-- "questions") ?? []
         ChatWorkflowManager.sharedManager.currentQuestionsList = questionsList
    }

    public func exitFramework() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowChatView"), object: nil)
    }

}

public protocol BaseFrameworkLauncher {
    
    var callBackHandler : (([String: Any])->Void)? { get set }

    func launch(_ presentedViewController: UIViewController?)
    
    func launchChat(parameters: JSONDictionary, sender: UIImage?, receiver: UIImage?, currentQuestionsDict: JSONDictionary)
    
    func exitFramework()
}

open class ChatFrameworkLauncher: NSObject, BaseFrameworkLauncher {
    
    public var callBackHandler: (([String : Any]) -> Void)?
        
    public func launchChat(parameters: JSONDictionary, sender: UIImage?, receiver: UIImage?, currentQuestionsDict: JSONDictionary) {
        ChatSession.deleteImages()
        if let senderIcon = sender {
            ChatSession.store(image: senderIcon, forKey: "sender", withStorageType: .fileSystem)
        }
        if let receiverIcon = receiver {
            ChatSession.store(image: receiverIcon, forKey: "receiver", withStorageType: .fileSystem)
        }
        UserDefaults.standard.set(parameters, forKey: "ChatData")
        UserDefaults.standard.synchronize()
   
        ChatWorkflowManager.sharedManager.performNavigationFor("ChatViewController", navType: NavType.model)
        let questionsList: [Questions] = (currentQuestionsDict <-- "questions") ?? []
        ChatWorkflowManager.sharedManager.currentQuestionsList = questionsList
    }
    
    public func launch(_ presentedViewController: UIViewController?) {
        
    }
    
    public func exitFramework() {
        
    }
    

}


 class ChatSession {
    
    class func baseURL() -> String {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let baseURL = chatData["baseURL"] as? String {
            return baseURL
        }
        return EMPTY_STRING
    }
    
    class func sessionToken() -> String {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let sessionToken = chatData["sessionToken"] as? String {
            return sessionToken
        }
        return EMPTY_STRING
    }
    
    class func title() -> String {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let title = chatData["title"] as? String {
            return title
        }
        return EMPTY_STRING
    }
    
    class func fontSize() -> CGFloat {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let fontSize = chatData["fontSize"] as? CGFloat {
            return fontSize
        }
        return 0.0
    }
    
    class func messageURL() -> String {
        return "user-query-v1/"
    }
    
    class func historyURL() -> String {
        return "chat/history/?page_size=20"
    }
        
    class func colorCode() -> String {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let colorCode = chatData["colorCode"] as? String {
            return colorCode
        }
        return EMPTY_STRING
    }
    
    class func senderTitle() -> String {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let senderTitle = chatData["senderTitle"] as? String {
            return senderTitle
        }
        return EMPTY_STRING
    }
    
    class func receiveTitle() -> String {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let receiveTitle = chatData["receiveTitle"] as? String {
            return receiveTitle
        }
        return EMPTY_STRING
    }
    
    class func currencySymbol() -> String {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let currencySymbol = chatData["currencySymbol"] as? String {
            return currencySymbol
        }
        return EMPTY_STRING
    }

    class func senderIcon() -> UIImage? {
        if let image = self.retrieveImage(forKey: "sender", inStorageType: .fileSystem) {
            return image
        }
        return nil
    }
    
    class func receiveIcon() -> UIImage? {
        if let image = self.retrieveImage(forKey: "receiver", inStorageType: .fileSystem) {
            return image
        }
        return nil
    }

    class func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }

    class func store(image: UIImage,
                        forKey key: String,
                        withStorageType storageType: StorageType) {
        if let pngRepresentation = image.pngData() {
            switch storageType {
            case .fileSystem:
                if let filePath = filePath(forKey: key) {
                    do  {
                        try pngRepresentation.write(to: filePath,
                                                    options: .atomic)
                    } catch let err {
                        print("Saving file resulted in error: ", err)
                    }
                }
            case .userDefaults:
                UserDefaults.standard.set(pngRepresentation,
                                            forKey: key)
            }
        }
    }

    class func retrieveImage(forKey key: String,
                                inStorageType storageType: StorageType) -> UIImage? {
        switch storageType {
        case .fileSystem:
            if let filePath = self.filePath(forKey: key),
                 let image = UIImage(contentsOfFile: filePath.path) {
                return image
            }
        case .userDefaults:
            if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        }
        return nil
    }
    
    class func deleteImages() {
        if let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                for fileURL in fileURLs {
                    if fileURL.pathExtension == "png" {
                        try FileManager.default.removeItem(at: fileURL)
                    }
                }
            } catch  { print(error) }
        }
    }

}

extension UIViewController {
    func presentAlertWithTitle(title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) {
            (action: UIAlertAction) in //print("Youve pressed OK Button")
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
