//
//  ChatDBMessageUpdateOperation.swift
//  ChatApp
//
//  Created by saran on 24/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation
import CoreData

class ChatDBMessageUpdateOperation: DBUpdateOperation {
    let dateFormatter = DateFormatter()
    var operationType: MessageUpdateOperationTypes
    var isFetchedViaListMessages: Bool = true
    init(operationType: MessageUpdateOperationTypes, data: AnyObject?, isFetchedViaListMessages: Bool = true, delegate: DBUpdateOperationDelegate?, parentManagedObjectContext: NSManagedObjectContext) {
        self.operationType = operationType
        self.isFetchedViaListMessages = isFetchedViaListMessages
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSz"
        self.dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        super.init(data: data, delegate: delegate, parentManagedObjectContext: parentManagedObjectContext)
    }
    
    override func main() {
        switch self.operationType {
        case .DetailsUpdate:
            self.importMessages()
        case .CopyUnsentMessage:
            self.copyUnsentMessageDetails()
        case .OtherAttributeUpdate:
            self.updateValue()
        case .ListMessagesUpdate:
            self.listMessagesUpdate()
        case . MessageUpdate:
            self.updateMessageDetails()
        case . BatchUpdate:
            self.updateSuggestionQuestions()
        }
        // Save Changes
        self.saveChanges()
    }
    private func importMessages() {
        self.managedObjectContext.performAndWait ({
            if let data = self.data as? [NSDictionary] {
                for messageContent: NSDictionary in data {
                    if let message = messageContent["message_content"] as? NSDictionary {
                            self.insertMessage(messageDetails: message, existingMessageObject: nil)
                    }
                }
            }
        })
    }
    private func listMessagesUpdate() {
        self.managedObjectContext.performAndWait ({
            if let data = self.data as? [[String: Any]] {
                for object in data {
                    if let message = object["message_content"] as? [String: Any], let messageID = message["messageId"] as? Int16 {
                        self.insertMessage(messageDetails: message as NSDictionary, existingMessageObject: nil)
//                        ChatCoreDataManager.getMessageWithID(messageID, context: self.managedObjectContext)   { (object) -> Void in
//                            self.insertMessage(messageDetails: message as NSDictionary, existingMessageObject: object)
//                        }
                    }
                }
                ChatDBUpdateManager.shared.callback?(true)
            }
        })
    }
    private func updateSuggestionQuestions() {
        // Reset last message for user, if exist already. otherwise ignore
        ChatCoreDataManager.getSuggestionQuestionObjects(context: self.managedObjectContext, completionHandler: { (array) in
            if let objects = array {
                for object in objects {
                    if let message = object as? ChatDBMessage {
                        message.setValue(false, forKey: "canShowSuggestions")
                    }
                }
            }
        })
    }
    private func insertMessage(messageDetails message: NSDictionary, existingMessageObject: NSManagedObject? = nil) {
        var messageVar : NSManagedObject!
        if let _ = existingMessageObject {
            messageVar = existingMessageObject
        } else {
            guard let entity =  NSEntityDescription.entity(forEntityName: "ChatDBMessage", in: self.managedObjectContext) else {
                fatalError("ChatDBMessage entity not found")
            }
            messageVar = NSManagedObject(entity: entity,
                                         insertInto: self.managedObjectContext)
            if let _ = message["messageId"] as? Int16, let messageCountt = UserDefaults.standard.integer(forKey: messageCount) as? Int {
                //FIX:- Later
                let messageID = messageCountt + 1
                UserDefaults.standard.set(messageID, forKey: messageCount)
                UserDefaults.standard.synchronize()
                messageVar.setValue(messageID, forKey: "messageId")
            }
        }

        if let timeInterval = message["sentDate"] as? String, let doubleTimeInterval = Double(timeInterval) {
            //FIX:- Later
//            let date = Date(timeIntervalSince1970: doubleTimeInterval)
            messageVar.setValue(Date(), forKey: "postedAt")
        } else {
            messageVar.setValue(Date(), forKey: "postedAt")
        }
        if let body = message["body"] as? String {
            messageVar.setValue(body, forKey: "body")
        }
        if let displayNotes = message["display_notes"] as? String {
                messageVar.setValue(displayNotes, forKey: "displayNotes")
        }
        if let userID = message["userID"] as? Int16 {
            messageVar.setValue(userID, forKey: "userID")
        }
        if let displayType = message["display_type"] as? String {
            messageVar.setValue(getHeightValue(displayTypeName: displayType), forKey: "chatHeight")
            messageVar.setValue(false, forKey: "canShowSuggestions")
            if self.operationType == .DetailsUpdate,
                 displayType == DisplayType.verticalQuestions.rawValue || displayType == DisplayType.horizontalQuestions.rawValue {
                    messageVar.setValue(true, forKey: "canShowSuggestions")
            }
            messageVar.setValue(displayType, forKey: "displayType")
        }
        if let kindDict = message["kind"] as? [String: Any] {
            messageVar.setValue(kindDict, forKey: "kind")
        }
        if let mediaType = message["media_type"] as? String {
            messageVar.setValue(mediaType, forKey: "mediaType")
        }
        if let mediaURL = message["media_url"] as? String {
            messageVar.setValue(mediaURL, forKey: "mediaURL")
        }
        messageVar.setValue(MessageStatus.Published.rawValue, forKey: "status")
    }
    
    func getHeightValue(displayTypeName: String) -> Double {
        let displayType: DisplayType = DisplayType(rawValue: displayTypeName)!
        var height: Double = 0.0
        switch displayType {
            case .messageWithChart:
                height = 270.0
            case .messageWithPieChart:
                height = 135.0
            case .cardRecommendation:
                height = 160.0
            case .horizontalQuestions: height = 0.0
            case .verticalQuestions: height = 0.0
            case .messageWithNotes: height = 0.0
            default: height = 0.0
        }
        return height
    }
    
    func parseDuration(_ timeString:String) -> TimeInterval {
        guard !timeString.isEmpty else {
            return 0
        }
        var interval:Double = 0
        let parts = timeString.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        return interval
    }
    
    private func updateValue() {
        self.managedObjectContext.performAndWait ({
            if let message = self.data as? NSDictionary {
                if let messageID = message["id"] as? Int16 {
                    ChatCoreDataManager.getMessageWithID(messageID, context: self.managedObjectContext) { (object) -> Void in
                        // Update if the message object exists already, else ignore
                        if let existingMessageObject = object {
                            self.updateValue(message, forMessage: existingMessageObject)
                        }
                    }
                }
            }
        })
    }
    private func updateValue(_ messageDetails: NSDictionary, forMessage existingMessageObject: NSManagedObject) {
        for key in messageDetails.allKeys {
            if let keyString = key as? String {
                existingMessageObject.setValue(messageDetails[key], forKey: keyString)
            }
        }
    }
    
    private func copyUnsentMessageDetails() {
        if let unsentMessageID = self.data as? Int16 {
            print("unsentMessageID: \(unsentMessageID)")
            // If message object exists already, ignore
            guard let unsentMessage = ChatCoreDataManager.getUnsentMessage(withID: unsentMessageID, context: self.managedObjectContext) as? ChatDBUnsentMessage
                else {
                    return
            }
            ChatCoreDataManager.getMessageWithID(unsentMessageID, context: self.managedObjectContext)   { (object) -> Void in
                if let _ = object as? ChatDBMessage {
                    return
                }
            }
            guard let entity =  NSEntityDescription.entity(forEntityName: "ChatDBMessage", in: self.managedObjectContext) else {
                fatalError("ChatDBMessage entity not found")
            }
            let messageVar = NSManagedObject(entity: entity,
                                             insertInto: self.managedObjectContext)
            messageVar.setValue(unsentMessage.messageId, forKey: "messageId")
            messageVar.setValue(unsentMessage.body, forKey: "body")
            messageVar.setValue(unsentMessage.postedAt, forKey: "postedAt")
            messageVar.setValue(MessageStatus.Published.rawValue, forKey: "status")
            messageVar.setValue(unsentMessage.userID, forKey: "userID")
        }
    }
    
    private func updateMessageDetails() {
        if let messageID = self.data as? Int {
            ChatCoreDataManager.getMessageWithID(Int16(messageID), context: self.managedObjectContext)   { (object) -> Void in
                var messageVar : NSManagedObject!
                if let _ = object {
                    messageVar = object
                    messageVar.setValue(false, forKey: "canShowSuggestions")
                    print("UPDATED")
                }
            }
        }
    }
    
}
