//
//  ChatDBUnsentMessage+CoreDataClass.swift
//  ChatApp
//
//  Created by saran on 24/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import CoreData

class ChatDBUnsentMessage: NSManagedObject {
    // Since we are not able to map a optional scalar type as @NSManaged type to entity, we are adding custom getters and setters
    
    var messageId: Int16?
    {
        get {
            self.willAccessValue(forKey: "messageId")
            let value = self.primitiveValue(forKey: "messageId") as? Int16
            self.didAccessValue(forKey: "messageId")
            
            return (value != nil) ? value! : nil
        }
        set {
            self.willChangeValue(forKey: "messageId")
            let value : Int16? = (newValue != nil) ? newValue! : nil
            self.setPrimitiveValue(value, forKey: "messageId")
            
            self.didChangeValue(forKey: "messageId")
        }
    }
    // Returns the payload used for creating message
    
    func payload(clientTempId: Double? = nil) -> [String: AnyObject] {
        var payload: [String: AnyObject] = [:]
        if let _clientTempId = clientTempId {
            payload["chat_reference_id"] = String(_clientTempId) as AnyObject
        }
        if let text = self.body {
            payload["query_txt"] = text  as AnyObject
        }
        payload["query_mode"] = "text" as AnyObject
        payload["device_type"] = "iOS" as AnyObject
        return payload
    }}
