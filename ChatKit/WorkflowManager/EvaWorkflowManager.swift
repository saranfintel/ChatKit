//
//  ChatWorkflowManager.swift
//  ChatKit
//
//  Created by saran on 20/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation
import UIKit

public enum NavType: String {
    case push = "push"
    case model = "model"
}

open class ChatWorkflowManager: NSObject {
    
    open class var sharedManager: ChatWorkflowManager {
        struct Singleton {
            static let instance = ChatWorkflowManager()
        }
        return Singleton.instance
    }
    
    fileprivate var bundleName: String {
        return "com.aws.payment.EvaKit"
    }
    
    fileprivate var moduleAppID: String {
        return "EvaInsights"
    }
    
    var appDelegate: UIApplicationDelegate? {
        return UIApplication.shared.delegate
    }

    static var bundle: Bundle {
        return Bundle(for: self.classForCoder())
    }

    open func performNavigationFor(_ vcName: String, navType: NavType, transitionWillStart: ((AnyObject) -> Void)? = nil, transitionDidFinish: ((AnyObject) -> Void)? = nil) {
        switch navType {
        case .model:
            if let topVC = appDelegate?.window??.rootViewController  {
                let nv = VCNames.chatVC.navObject
                nv.modalPresentationStyle = .fullScreen
                topVC.present(nv, animated: true, completion: nil)
            }
        default:
            if let navVC = appDelegate?.window??.rootViewController as? UINavigationController {
                let chatVC = VCNames.chatVC.controllerObject
                navVC.pushViewController(chatVC, animated: true)
            }
        }
    }
    
}

