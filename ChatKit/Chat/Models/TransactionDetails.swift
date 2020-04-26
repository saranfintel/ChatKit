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
    var accounts: [Account] = []
}


extension Transactions: Mappable {
    
    static func empty() -> Transactions {
        return Transactions(suggestions: [], accounts: [])
    }
    
    static func Map(_ json: JSONObject) -> Transactions? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        let suggestions: [Suggestions] = (d <-- "questionsList") ?? []
        let accounts : [Account] = (d <-- "account_data") ?? []
        return Transactions(suggestions: suggestions, accounts: accounts)
    }
    
}

struct Suggestions {
    var question: String = EMPTY_STRING
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
