//
//  ChatFrameworkLauncher.swift
//  ChatKit
//
//  Created by saran on 20/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation
import UIKit

public protocol BaseFrameworkLauncher {
    
    var callBackHandler : (([String: Any])->Void)? { get set }

    func launch(_ presentedViewController: UIViewController?)
    
    func launchChat(parameters: JSONDictionary)
    
    func exitFramework()
}

open class ChatFrameworkLauncher: NSObject, BaseFrameworkLauncher {
    
    public var callBackHandler: (([String : Any]) -> Void)?
        
    public func launchChat(parameters: JSONDictionary) {
        UserDefaults.standard.set(parameters, forKey: "ChatData")
        UserDefaults.standard.synchronize()
        ChatLaunchServiceHandler.sharedManager.launchChatView()
    }
    
    public func launch(_ presentedViewController: UIViewController?) {
        
    }
    
    public func exitFramework() {
        
    }
}


 class ChatLaunchServiceHandler: NSObject {
    
    open class var sharedManager: ChatLaunchServiceHandler {
        struct Singleton {
            static let instance = ChatLaunchServiceHandler()
        }
        return Singleton.instance
    }

    public func launchChatView() {
        ChatWorkflowManager.sharedManager.performNavigationFor("ChatViewController", navType: NavType.push)
    }

    func baseURL() -> String {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let baseURL = chatData["baseURL"] as? String {
            return baseURL
        }
        return EMPTY_STRING
    }
    
    func messageURL() -> String {
        return "user-query-v1/"
    }
    
    func historyURL() -> String {
        return "chat/history/?page_size=20"
    }
    
    func colorCode() -> String {
        if let chatData = UserDefaults.standard.object(forKey: "ChatData") as? JSONDictionary, let colorCode = chatData["colorCode"] as? String {
            return colorCode
        }
        return EMPTY_STRING
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
