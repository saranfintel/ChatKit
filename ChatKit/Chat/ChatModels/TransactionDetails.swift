//
//  TransactionDetails.swift
//  ChatKit
//
//  Created by saran on 23/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import UIKit
import Foundation

struct Transactions {
    var suggestions: [Suggestions] = []
}


extension Transactions: Mappable {
    
    static func empty() -> Transactions {
        return Transactions(suggestions: [])
    }
    
    static func Map(_ json: JSONObject) -> Transactions? {
        guard let d: JSONDictionary = Parse(json), let _payload = d["payload"] as? Dictionary<String, Any> else {
            return nil
        }
        let suggestions: [Suggestions] = (_payload <-- "questionsList") ?? []
        return Transactions(suggestions: suggestions)
    }
}

struct Suggestions {
    var question: String = ""
}

extension Suggestions: Mappable {
    
    static func empty() -> Suggestions {
        return Suggestions(question: EMPTY_STRING)
    }
    
    static func Map(_ json: JSONObject) -> Suggestions? {
        guard let question = json as? String else {
            return nil
        }
        return Suggestions(question: question)
    }
    
}
