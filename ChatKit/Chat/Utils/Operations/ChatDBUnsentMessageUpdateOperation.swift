//
//  ChatDBUnsentMessageUpdateOperation.swift
//  ChatApp
//
//  Created by saran on 24/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation
import CoreData

class ChatDBUnsentMessageUpdateOperation: DBUpdateOperation {
    var operationType: UnsentMessageUpdateOperationTypes
    var teamSlug: String? = nil
    init(operationType: UnsentMessageUpdateOperationTypes, data: AnyObject?, delegate: DBUpdateOperationDelegate?, parentManagedObjectContext: NSManagedObjectContext) {
        self.operationType = operationType
        super.init(data: data, delegate: delegate, parentManagedObjectContext: parentManagedObjectContext)
    }
    
    override func main() {
        switch self.operationType {
        case .DetailsUpdate:
            self.importMessages()
        case .OtherAttributeUpdate:
            self.updateValue()
        case .ObjectDelete:
            self.deleteObject()
        }
        // Save Changes
        self.saveChanges()
    }
    private func importMessages() {
        self.managedObjectContext.performAndWait ({
            if let data = self.data as? [NSDictionary] {
                for message: NSDictionary in data {
                    if let clientTempID = message["clientTempID"] as? Double {
                        ChatCoreDataManager.getUnsentMessage(withClientTempID: clientTempID, context: self.managedObjectContext)   { (object) -> Void in
                            self.insertUnsentMessage(messageDetails: message, existingUnsentMessageObject: object)
                        }
                    }
                }
            }
        })
    }
    private func insertUnsentMessage(messageDetails message: NSDictionary, existingUnsentMessageObject: NSManagedObject? = nil) {
        var unsentMessageVar : ChatDBUnsentMessage!
        if let _ = existingUnsentMessageObject as? ChatDBUnsentMessage {
            unsentMessageVar = existingUnsentMessageObject as! ChatDBUnsentMessage
        } else {
            guard let entity =  NSEntityDescription.entity(forEntityName: "ChatDBUnsentMessage", in: self.managedObjectContext) else {
                fatalError("ChatDBUnsentMessage entity not found")
            }
            unsentMessageVar = NSManagedObject(entity: entity,
                                               insertInto: self.managedObjectContext) as? ChatDBUnsentMessage
            unsentMessageVar.setValue(message["clientTempID"], forKey: "clientTempID")
        }
        unsentMessageVar.setValue(message["body"], forKey: "body")
        if let userID = message["userID"] as? Int16 {
            unsentMessageVar.setValue(userID, forKey: "userID")
        }
        if let posted_at = message["postedAt"] as? Date {
            unsentMessageVar.setValue(posted_at, forKey: "postedAt")
        }
        if let status = message["status"] as? MessageStatus {
            unsentMessageVar.setValue(status.rawValue, forKey: "status")
        }
        if let displayType = message["displayType"] as? String {
            unsentMessageVar.setValue(displayType, forKey: "displayType")
        }
    }
    
    private func updateValue() {
        self.managedObjectContext.performAndWait ({
            if let unsentMessage = self.data as? NSDictionary {
                if let clientTempID = unsentMessage["clientTempID"] as? Double {
                    ChatCoreDataManager.getUnsentMessage(withClientTempID: clientTempID, context: self.managedObjectContext) { (object) -> Void in
                        // Update if the unsent message object exists already, else ignore
                        if let existingObject = object {
                            self.updateValue(unsentMessage, forUnsentMessage: existingObject)
                        }
                    }
                }
            }
        })
    }
    private func updateValue(_ messageDetails: NSDictionary, forUnsentMessage existingMessageObject: NSManagedObject) {
        for key in messageDetails.allKeys {
            if let keyString = key as? String {
                existingMessageObject.setValue(messageDetails[key], forKey: keyString)
            }
        }
    }
    
    private func deleteObject() {
        self.managedObjectContext.performAndWait ({
            if let unsentMessage = self.data as? NSDictionary {
                if let clientTempID = unsentMessage["clientTempID"] as? Double {
                    ChatCoreDataManager.getUnsentMessage(withClientTempID: clientTempID, context: self.managedObjectContext) { (object) -> Void in
                        if let _ = object {
                            self.managedObjectContext.delete(object!)
                        }
                    }
                }
            }
        })
    }
    
}
