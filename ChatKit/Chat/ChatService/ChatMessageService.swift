//
//  ChatMessageService.swift
//  ChatApp
//
//  Created by Sarankumar on 29/08/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit

class ChatMessageService: NSObject {
    
    //Push notificaion params added
    var deviceType = "ios"

    static let shared = ChatMessageService()
    func postMessage(withClientTempId clientTempId: Double,_ completionHandler: @escaping ChatCompletionHandler) {
        // get the unsent message from the DB and form the payload to be sent for message creation
        ChatCoreDataManager.getUnsentMessage(withClientTempID: clientTempId, context: ChatCoreDataStack.sharedInstance.mainManagedObjectContext) { (object) in
            if let unsentMessage = object as? ChatDBUnsentMessage {
                let parameters = unsentMessage.payload(clientTempId: clientTempId)
                print("parameters: \(parameters)")
                ChatBWService.request("https://stage.evamoney.io/api/user-query-v1/", method: .post, parameters: parameters) { (isSuccess, result, error) in
                    completionHandler(isSuccess, result, error)
                }
            }
        }
    }
    
    func getListMessages(messageID: Int16? = nil, completionHandler: @escaping ChatCompletionHandler) {
        var url = "https://stage.evamoney.io/api/chat/history/?page_size=20"
        if let id = messageID {
            url = "\(url)&message_id=\(id)"
        }
        ChatBWService.request(url, method: .get, parameters: nil) { (isSuccess, result, error) in
            completionHandler(isSuccess, result, error)
        }
    }
    
}
