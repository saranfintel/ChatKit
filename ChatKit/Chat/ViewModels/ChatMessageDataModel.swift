//
//  ChatMessageDataModel.swift
//  ChatApp
//
//  Created by saran on 25/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit

class ChatMessageDataModel: NSObject {
    //MARK:- Post Message
    class func postMessage(withClientTempId tempID: Double, completionHandler: ChatCompletionHandler? = nil) {
        ChatMessageService.shared.postMessage(withClientTempId: tempID){ (isSuccess, result, error) in
            if isSuccess, let dict = result as? [String: Any], let messsageArray = dict["payload"] as? [[String : Any]] {
                    let unsentMesssageDict = messsageArray[0]
                ChatMessageDataModel.messagePostSuccessHandler(messageDict: unsentMesssageDict, clientTempID: tempID, completionHandler: { (isSuccess, resultt, error) in
                    //Added DispatchQueue delay for Insertion new messages
                    for (index, object) in messsageArray.enumerated() {
                        if index != 0 {
                            ChatMessageDataModel.insertNewMessage(messsageDict: object)
                        }
                    }
                })
                completionHandler?(isSuccess, result, error)
            } else {
                ChatMessageDataModel.messagePostFailureHandler(clientTempID: tempID)
            }
        }
    }
    class func insertUnsentMessageToDB(fromMessageDetails messageDict: [String: AnyObject], teamSlugName: String? = nil, completionHandler: ChatCompletionHandler?) {
        //Update Suggestion Questions
        ChatMessageDataModel.updateSuggestionQuestions()
        //Insert Messages
        let operation = ChatDBUnsentMessageUpdateOperation(operationType: .DetailsUpdate, data: [messageDict] as AnyObject?, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
        operation.queuePriority = .veryHigh
        ChatDBUpdateManager.shared.operationQueue.addOperation(operation)
        operation.completionBlock = {
            if let status = messageDict["status"] as? MessageStatus {
                // post the message directly if there are no attachments
                if status == MessageStatus.Sending {
                    operation.completionBlock = nil
                    self.postMessage(withClientTempId: messageDict["clientTempID"] as! Double, completionHandler: { (isSuccess, result, error) in
                        completionHandler?(isSuccess, result, error)
                    })
                }
            }
        }
    }
    //MARK:- List Messages
    class func listMessagesHandler(messageID: Int16? = nil,completionStatusHandler: @escaping CompletionStatusHandler) {
       ChatMessageService.shared.getListMessages(messageID: messageID){ (isSuccess, result, error) in
       guard  isSuccess, let dict = result as? [String: Any], let results = dict["payload"] as? [[String: Any]], results.count > 0, let _ = results[0]["message_id"] as? Int else {
             completionStatusHandler(false)
           return
           
       }
                     let msgUpdateOperation = ChatDBMessageUpdateOperation(operationType: .ListMessagesUpdate, data: results as AnyObject?, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
                     ChatDBUpdateManager.shared.operationQueue.addOperation(msgUpdateOperation)
       ChatDBUpdateManager.shared.callback = { _ in
           completionStatusHandler(true)
       }
       
             }
    }

    class func insertNewMessage(messsageDict: [String: Any]) {
        let msgUpdateOperation = ChatDBMessageUpdateOperation(operationType: .DetailsUpdate, data: [messsageDict] as AnyObject?, isFetchedViaListMessages: false, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
        msgUpdateOperation.queuePriority = .veryHigh
        msgUpdateOperation.completionBlock = {
            msgUpdateOperation.completionBlock = nil
        }
        ChatDBUpdateManager.shared.operationQueue.addOperation(msgUpdateOperation)
    }
    class func statusMessagePayload(messageDict: [String: Any], clientTempID: Double) -> [String: Any] {
        var statusDict: [String: Any] =  ["clientTempID": clientTempID as AnyObject]
        if let messageID = messageDict["messageId"] as? Int16 {
            statusDict["messageId"] = messageID as Any?
        }
        if let displayType = messageDict["displayType"] as? Int16 {
            statusDict["displayType"] = displayType as Any?
        }
        if let timeInterval = messageDict["sentDate"] as? String {
            let date = Date(timeIntervalSince1970: Double(timeInterval) ?? 0.0)
            statusDict["postedAt"] = date as Any?
        }
        statusDict["status"] = MessageStatus.Published.rawValue as Any?
        return statusDict
    }
    class func messagePostSuccessHandler(messageDict: [String: Any], clientTempID: Double, completionHandler: ChatCompletionHandler? = nil) {
        let statusDict = statusMessagePayload(messageDict: messageDict, clientTempID: clientTempID)
        // Update id, postedAt, status
        let operation = ChatDBUnsentMessageUpdateOperation(operationType: .OtherAttributeUpdate, data: statusDict as AnyObject?, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
        operation.queuePriority = .veryHigh
        operation.completionBlock = {
            // copy this unsent message to DBMessages
            DispatchQueue.main.async {
                ChatCoreDataManager.getUnsentMessage(withClientTempID: clientTempID, context: ChatCoreDataStack.sharedInstance.mainManagedObjectContext, completionHandler: { (object) in
                    if let unsentMessage = object as? ChatDBUnsentMessage {
                        let msgUpdateOperation = ChatDBMessageUpdateOperation(operationType: .CopyUnsentMessage, data: unsentMessage.messageId as AnyObject?, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
                        msgUpdateOperation.queuePriority = .veryHigh
                        msgUpdateOperation.completionBlock = {
                            completionHandler?(true, nil, nil)
                            msgUpdateOperation.completionBlock = nil
                        }
                        ChatDBUpdateManager.shared.operationQueue.addOperation(msgUpdateOperation)
                        operation.completionBlock = nil
                        // after copying, remove the message from Unsent messages
                        let operation = ChatDBUnsentMessageUpdateOperation(operationType: .ObjectDelete, data: ["clientTempID" : clientTempID] as AnyObject?, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
                        operation.queuePriority = .veryHigh
                        operation.completionBlock = {
                            //don't uncomment this - callback returning twice 1. msgUpdateOperation, 2.operation
                            //completionHandler?(true, nil, nil)
                            operation.completionBlock = nil
                        }
                        ChatDBUpdateManager.shared.operationQueue.addOperation(operation)

                    } else {
                        completionHandler?(true, nil, nil)
                    }
                })
            }
        }
        ChatDBUpdateManager.shared.operationQueue.addOperation(operation)
        // Need not update status in case of failure here. On fifth retry failure, failed status can be updated
    }
    
    
    class func messagePostFailureHandler(clientTempID tempID: Double) {
        // On failure, update the retry count, status as necessary and try resending the message if retry count is less than 5
        ChatCoreDataManager.getUnsentMessage(withClientTempID: tempID, context: ChatCoreDataStack.sharedInstance.mainManagedObjectContext, completionHandler: { (object) in
            if let message = object as? ChatDBUnsentMessage {
                // check created status to avoid duplicate message post
                if Int(message.status) == MessageStatus.Sending.rawValue {
                    if message.noOfRetry >= 5 {
                        // If failed for more than 5 times, update as failed and stop retrying
                        let statusDict: [String: AnyObject] =  ["clientTempID": tempID as AnyObject, "status": (MessageStatus.Failed.rawValue as AnyObject?)!, "noOfRetry" : 0 as AnyObject]
                        let operation = ChatDBUnsentMessageUpdateOperation(operationType: .OtherAttributeUpdate, data: statusDict as AnyObject?, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
                        operation.queuePriority = .veryHigh
                        ChatDBUpdateManager.shared.operationQueue.addOperation(operation)
                    } else {
                        let clientTempID = Date().epochTimeRoundedTo13Digits()
                        if (clientTempID - message.clientTempID) < timeoutForSendingMessages {
                            // If retry count did not reach threshold, increament retry count and attempt sending message
                            let operation = ChatDBUnsentMessageUpdateOperation(operationType: .OtherAttributeUpdate, data: ["clientTempID": tempID, "noOfRetry" : message.noOfRetry + 1] as AnyObject?, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
                            operation.queuePriority = .veryHigh
                            operation.completionBlock = {
                                ChatMessageDataModel.postMessage(withClientTempId: tempID)
                                operation.completionBlock = nil
                            }
                            ChatDBUpdateManager.shared.operationQueue.addOperation(operation)
                        } else {
                            ChatMessageDataModel.timeOutErrorHandlerForMessage(withClientTempID: tempID)
                        }
                    }
                }
            } else {
                ChatMessageDataModel.messagePostFailureHandler(clientTempID: tempID)
            }
        })
    }
    class func timeOutErrorHandlerForMessage(withClientTempID tempID: Double) {
        // If failed for more than 5 times, update as failed and stop retrying
        let statusDict: [String: AnyObject] =  ["clientTempID": tempID as AnyObject, "status": (MessageStatus.Failed.rawValue as AnyObject?)!, "noOfRetry" : 0 as AnyObject]
        let operation = ChatDBUnsentMessageUpdateOperation(operationType: .OtherAttributeUpdate, data: statusDict as AnyObject?, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
        operation.queuePriority = .veryHigh
        ChatDBUpdateManager.shared.operationQueue.addOperation(operation)
    }
    class func sentMessage(withClientTempID tempID: Double) {
        let operation = ChatDBUnsentMessageUpdateOperation(operationType: .OtherAttributeUpdate, data: ["clientTempID": tempID, "noOfRetry": 1, "status": (MessageStatus.Sending.rawValue as AnyObject?)!] as AnyObject?, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
        operation.queuePriority = .veryHigh
        operation.completionBlock = {
            ChatMessageDataModel.postMessage(withClientTempId: tempID)
            operation.completionBlock = nil
        }
        ChatDBUpdateManager.shared.operationQueue.addOperation(operation)
    }
    
    class func retryAllUnsentMessages() {
        DispatchQueue.main.async {
            // get all unsent messages from db except the already failed ones.. and retry
            if let unsentMessages = ChatCoreDataManager.getAllUnsentMessagesForRetry(context: ChatCoreDataStack.sharedInstance.mainManagedObjectContext), unsentMessages.count > 0 {
                for unsentMessage in unsentMessages {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.sentMessage(withClientTempID: unsentMessage.clientTempID)
                    }
                }
            }
        }
    }
    class func delete(unsentMessageWithClientTempId tempID: Double) {
        let operation = ChatDBUnsentMessageUpdateOperation(operationType: .ObjectDelete, data: ["clientTempID" : tempID] as AnyObject,  delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
        ChatDBUpdateManager.shared.operationQueue.addOperation(operation)
    }
    class func messagePayloadDictionary(forText body: String? = nil) -> [String: AnyObject]? {
        let clientTempID = Date().epochTimeRoundedTo13Digits()
        let postedAt = Date().epochTimeRoundedTo9Digits()
        let date = Date(timeIntervalSince1970: postedAt)
        let messageVar: [String: AnyObject] = ["body": body as AnyObject? ?? "" as AnyObject, "clientTempID": clientTempID as AnyObject, "userID": 1 as AnyObject, "postedAt": date as AnyObject, "status" : MessageStatus.Sending as AnyObject]
        return messageVar
    }
    
    class func updateSuggestionQuestions() {
        let msgUpdateOperation = ChatDBMessageUpdateOperation(operationType: .BatchUpdate, data: nil, isFetchedViaListMessages: false, delegate: nil, parentManagedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext)
        msgUpdateOperation.queuePriority = .veryHigh
        msgUpdateOperation.completionBlock = {
            msgUpdateOperation.completionBlock = nil
        }
        ChatDBUpdateManager.shared.operationQueue.addOperation(msgUpdateOperation)
    }

}
