//
//  Questions.swift
//  ChatKit
//
//  Created by saran on 03/05/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation
import UIKit

public struct Questions {
    var group_id: Int = EMPTY_INT
    var category: String = EMPTY_STRING
    var question_text: String = EMPTY_STRING
}

extension Questions: Mappable {
    
    static func empty() -> Questions {
        return Questions(group_id: EMPTY_INT, category: EMPTY_STRING, question_text: EMPTY_STRING)
    }
    
    public static func Map(_ json: JSONObject) -> Questions? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        
        let group_id = (d <-  "group_id") ?? EMPTY_INT
        let category = (d <-  "category") ?? EMPTY_STRING
        var question_text = (d <-  "question_text") ?? EMPTY_STRING
        question_text = (d <-  "text") ?? EMPTY_STRING
        return Questions(group_id: group_id, category: category, question_text: question_text)
    }
    
}
