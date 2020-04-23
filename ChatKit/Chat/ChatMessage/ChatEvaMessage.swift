//
//  ChatEvaMessage.swift
//  ChatApp
//
//  Created by pooma on 12/23/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation

struct ChatEvaMessage {
    
    var messageId: String
    var evaSender: EvaSender = EvaSender.empty()
    var sentDate: Date
    var kind: Any?
}

extension ChatEvaMessage: Mappable {
    
    static func empty() -> ChatEvaMessage {
        return ChatEvaMessage(messageId: EMPTY_STRING, evaSender: EvaSender.empty(), sentDate: Date(), kind: nil)
    }
    
    static func Map(_ json: JSONObject) -> ChatEvaMessage? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        //print(d)
        
        let messageId = (d <-  "messageId") ?? EMPTY_STRING
        let evaSender = (d <-  "sender") ?? EvaSender.empty()
        let sentDate = (d <-  "sentDate") ?? Date()
        let kind = d["kind"]

        return ChatEvaMessage(messageId: messageId, evaSender: evaSender, sentDate: sentDate, kind: kind)
    }
    
}


struct EvaSender {
    
    let id: String
    let displayName: String
}

extension EvaSender: Mappable {
    
    static func empty() -> EvaSender {
        return EvaSender(id: EMPTY_STRING, displayName: EMPTY_STRING)
    }
    
    static func Map(_ json: JSONObject) -> EvaSender? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        //print(d)
        
        let id = (d <-  "id") ?? EMPTY_STRING
        let displayName = (d <-  "displayName") ?? EMPTY_STRING

        return EvaSender(id: id, displayName: displayName)
    }
    
}
