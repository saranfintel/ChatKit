//
//  Account.swift
//  ChatKit
//
//  Created by saran on 24/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation
import UIKit

struct Account {
    
    // Details Property declration
    var institution_type: String = ""
    var institution_id: String = ""
    var institution_name: String = ""
    var name: String = ""
    var official_name: String = ""
    var color_scheme: String = ""
    var ending_number: String = ""
    var subtype: String = ""
    var available_balance: String = ""
    var current_balance: String = ""
    var credit_limit: String = ""
    var account_id: String = ""
    var utilization_as_value: String = ""
    var utilization_percent_as_text: String = ""
    var utilizaton_band: String = ""
    var payoff_value: String = ""
    var is_reconnect_required: String = ""
    var id: String = ""
    var item_id: String = ""
}

extension Account: Mappable {
    
    static func empty() -> Account {
        return Account(institution_type: EMPTY_STRING, institution_id: EMPTY_STRING, institution_name: EMPTY_STRING, name: EMPTY_STRING, official_name: EMPTY_STRING, color_scheme: EMPTY_STRING, ending_number: EMPTY_STRING , subtype : EMPTY_STRING, available_balance: EMPTY_STRING, current_balance: EMPTY_STRING, credit_limit: EMPTY_STRING,  account_id: EMPTY_STRING, utilization_as_value: EMPTY_STRING, utilization_percent_as_text: EMPTY_STRING, utilizaton_band: EMPTY_STRING, payoff_value: EMPTY_STRING,is_reconnect_required: EMPTY_STRING,id: EMPTY_STRING,item_id: EMPTY_STRING)
    }
    
    static func Map(_ json: JSONObject) -> Account? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        let institution_type = (d <-  "institution_type") ?? EMPTY_STRING
        var institution_id = (d <-  "institution_code") ?? EMPTY_STRING
        let institution_name = (d <-  "institution_name") ?? EMPTY_STRING
        let is_reconnect_required = (d <-  "is_reconnect_required") ?? false ? "TRUE" : "FALSE"
        let name = (d <- "name") ?? EMPTY_STRING
        let official_name = (d <- "official_name") ?? EMPTY_STRING
        let color_scheme = (d <- "institution_color_scheme") ?? EMPTY_STRING
        var ending_number = (d <- "mask") ?? EMPTY_STRING
        var subtype = (d <- "account_sub_type") ?? EMPTY_STRING
        let credit_limit = (d <- "balance_limit") ?? EMPTY_STRING
        let account_id = (d <- "account_id") ?? EMPTY_STRING
        let utilization_as_value = (d <- "utilization_as_value") ?? EMPTY_STRING
        var utilization_percent_as_text = (d <- "utilization_percent_as_text") ?? EMPTY_STRING
        let utilizaton_band = (d <- "utilizaton_band") ?? EMPTY_STRING
        let payoff_value = (d <- "payoff_value") ?? EMPTY_STRING
        var available_balance = EMPTY_STRING
        var current_balance = EMPTY_STRING
        // This is to handle balance both in Double or String format
        let _available: Any? = (d <-  "available_balance")
        let _current: Any? = (d <-  "current_balance")
        if let available = _available as? String, let current = _current as? String {
            available_balance = available
            current_balance = current
        } else if let available = _available as? Double, let current = _current as? Double {
            available_balance = available.formattedWithSeparator
            current_balance = current.formattedWithSeparator
        }

        // This is to convert utilization value to utilization string
        let _utilization: Any? = (d <- "utilization")
        if let utilization = _utilization as? Double {
            utilization_percent_as_text = String(format:"%.1f", utilization) + EMPTY_STRING + "%"
        }
        
        let _mask: Any? = (d <- "mask")
        if let mask = _mask as? Int {
            ending_number = String(format:"%d", mask)
        }
        
        let _institution_id: String = (d <- "institution_id") ?? EMPTY_STRING
        if _institution_id != "" {
            institution_id = _institution_id
        }

        let _subtype = (d <- "subtype") ?? EMPTY_STRING
        if _subtype != "" {
            subtype = _subtype
        }
            
        let id = String((d <- "id") ?? EMPTY_INT)
        let item_id = String((d <- "item_id") ?? EMPTY_INT)
        
        return Account(institution_type: institution_type, institution_id: institution_id, institution_name: institution_name, name: name, official_name: official_name, color_scheme: color_scheme, ending_number: ending_number , subtype : subtype, available_balance: available_balance, current_balance: current_balance, credit_limit: credit_limit,  account_id: account_id, utilization_as_value: utilization_as_value, utilization_percent_as_text: utilization_percent_as_text, utilizaton_band: utilizaton_band, payoff_value: payoff_value,is_reconnect_required: is_reconnect_required, id: id, item_id: item_id)
    }
    
}
