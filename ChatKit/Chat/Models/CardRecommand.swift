//
//  CardRecommand.swift
//  Eva
//
//  Created by Poomalai on 4/19/17.
//  Copyright © 2017 Eva. All rights reserved.
//

import Foundation


struct CardRecommands {
    var cardRecommands: [CardRecommand] = []
}


extension CardRecommands: Mappable{
    
    static func empty() -> CardRecommands {
        return CardRecommands(cardRecommands: [])
    }
    
    static func Map(_ json: JSONObject) -> CardRecommands? {
        guard let d: JSONDictionary = Parse(json) else {
            return empty()
        }
        let cardRecommands : [CardRecommand] = (d <-- "card_reco_data") ?? []
        return CardRecommands(cardRecommands: cardRecommands)
    }
}



struct CardRecommand {
    
    // Details Property declration
    var rank: Int = EMPTY_INT
    var total_thumbs_up: Int = EMPTY_INT
    var institution_id: String = ""
    var institution_name: String = ""
    var color_scheme: String = ""
    var image_name: String = ""
    var institution_type: String = ""
    var name: String = ""
    var official_name: String = ""
    var ending_number: String = ""
    var subtype: String = ""
    var available_balance: String = ""
    var current_balance: String = ""
    var credit_limit: String = ""
    var utilization_as_value: String = ""
    var utilizaton_band: String = ""
    var utilization_percent_as_text: String = ""
    var account_id: String = ""
    var notes: String = ""
}

extension CardRecommand: Mappable {
    
    static func empty() -> CardRecommand {
        return CardRecommand(rank: EMPTY_INT, total_thumbs_up: EMPTY_INT, institution_id: EMPTY_STRING, institution_name: EMPTY_STRING, color_scheme: EMPTY_STRING , image_name : EMPTY_STRING, institution_type: EMPTY_STRING, name: EMPTY_STRING, official_name: EMPTY_STRING,  ending_number: EMPTY_STRING, subtype: EMPTY_STRING, available_balance:EMPTY_STRING, current_balance: EMPTY_STRING, credit_limit: EMPTY_STRING, utilization_as_value: EMPTY_STRING, utilizaton_band: EMPTY_STRING, utilization_percent_as_text: EMPTY_STRING, account_id: EMPTY_STRING, notes: EMPTY_STRING)
    }
    
    static func Map(_ json: JSONObject) -> CardRecommand? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        
        let rank = (d <-  "rank") ?? EMPTY_INT
        let total_thumbs_up = (d <- "total_thumbs_up") ?? EMPTY_INT
        let institution_id = (d <- "institution_id") ?? EMPTY_STRING
        let institution_name = (d <- "institution_name") ?? EMPTY_STRING
        let color_scheme = (d <- "color_scheme") ?? EMPTY_STRING
        let image_name = (d <- "image_name") ?? EMPTY_STRING
        let institution_type = (d <- "institution_type") ?? EMPTY_STRING
        let name = (d <- "name") ?? EMPTY_STRING
        let official_name = (d <- "official_name") ?? EMPTY_STRING
        let ending_number = (d <- "ending_number") ?? EMPTY_STRING
        
        let subtype = (d <- "subtype") ?? EMPTY_STRING
        let available_balance = (d <- "available_balance") ?? EMPTY_STRING
        let current_balance = (d <- "current_balance") ?? EMPTY_STRING
        let credit_limit = (d <- "credit_limit") ?? EMPTY_STRING
        
        let utilization_as_value = (d <- "utilization_as_value") ?? EMPTY_STRING
        let utilization_percent_as_text = (d <- "utilization_percent_as_text") ?? EMPTY_STRING
        let utilizaton_band = (d <- "utilizaton_band") ?? EMPTY_STRING
        let account_id = (d <- "account_id") ?? EMPTY_STRING
        let notes = (d <- "notes") ?? EMPTY_STRING
        
        
        return CardRecommand(rank: rank, total_thumbs_up: total_thumbs_up, institution_id: institution_id, institution_name: institution_name, color_scheme: color_scheme , image_name : image_name, institution_type: institution_type, name: name, official_name: official_name,  ending_number: ending_number, subtype:subtype, available_balance: available_balance, current_balance:current_balance, credit_limit: credit_limit, utilization_as_value: utilization_as_value, utilizaton_band: utilizaton_band, utilization_percent_as_text: utilization_percent_as_text, account_id: account_id, notes: notes)
    }
    
}

