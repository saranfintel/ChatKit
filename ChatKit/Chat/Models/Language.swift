//
//  Language.swift
//  ChatApp
//
//  Created by pooma on 12/23/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation

struct Language {
    var fullText: String = EMPTY_STRING
    var locale: String = EMPTY_STRING
    var initial: String = EMPTY_STRING
}

extension Language: Mappable {
    
    static func empty() -> Language {
        return Language(fullText: EMPTY_STRING, locale: EMPTY_STRING, initial: EMPTY_STRING)
    }
    
    static func Map(_ json: JSONObject) -> Language? {
        guard let d: JSONDictionary = json as? JSONDictionary else {
            return nil
        }
        let fullText = (d <-  "fullText") ?? EMPTY_STRING
        let locale = (d <-  "locale") ?? EMPTY_STRING
        let initial = (d <-  "initial") ?? EMPTY_STRING
        return Language(fullText: fullText, locale: locale, initial: initial)
    }
    
}
