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
    
    func launchChat()
    
    func exitFramework()
}

open class ChatFrameworkLauncher: NSObject, BaseFrameworkLauncher {
    
    public var callBackHandler: (([String : Any]) -> Void)?
        
    public func launchChat() {
            ChatLaunchServiceHandler.sharedManager.launchChatView()
    }
    
    public func launch(_ presentedViewController: UIViewController?) {
        
    }
    
    public func exitFramework() {
        
    }
}


fileprivate class ChatLaunchServiceHandler: NSObject {
    
    open class var sharedManager: ChatLaunchServiceHandler {
        struct Singleton {
            static let instance = ChatLaunchServiceHandler()
        }
        return Singleton.instance
    }

    public func launchChatView() {
            self.parseUserQuery(output: "success", responseDict: nil)
    }
    
    func parseUserQuery(output: String?, responseDict: [String: Any]?) {
            ChatWorkflowManager.sharedManager.performNavigationFor("ChatViewController", navType: NavType.push)
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
