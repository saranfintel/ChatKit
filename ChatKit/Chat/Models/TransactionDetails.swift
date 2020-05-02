//
//  TransactionDetails.swift
//  ChatKit
//
//  Created by saran on 23/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import UIKit
import Foundation

struct TransactionDetails {
    
    // Details Property declration
    var account_id: String = EMPTY_STRING
    //This one only we are using..
    var account_name: String = EMPTY_STRING
    var account_type: String = EMPTY_STRING
    var amount: String = EMPTY_STRING
    var category0: String = EMPTY_STRING
    var category1: String = EMPTY_STRING
    var category2: String = EMPTY_STRING
    var category_display_text: String = EMPTY_STRING
    var display_amount: String = EMPTY_STRING
    var institution_id: String = EMPTY_STRING
    var institution_name: String = EMPTY_STRING
    var name: String = EMPTY_STRING
    var pending: String = EMPTY_STRING
    var transaction_date_as_display: String = EMPTY_STRING
    ///
    var transaction_date: String = EMPTY_STRING
    var category_emoji: String = EMPTY_STRING
    var address: String = EMPTY_STRING
    var city: String = EMPTY_STRING
    var state: String = EMPTY_STRING
    var zip: String = EMPTY_STRING
    var latitude: String = EMPTY_STRING
    var longitude: String = EMPTY_STRING
    var transaction_id: String = EMPTY_STRING
    
    // Init Method Assigning
    init(account_id: String, account_name: String, account_type: String, institution_id: String, institution_name: String, transaction_date: String, transaction_date_as_display: String, pending: String, amount: String, display_amount: String, name: String, category0:String, category1:String , category2 : String, category_display_text:String, category_emoji: String, address:String, city:String, state:String,  zip:String,latitude:String, longitude:String, transaction_id: String) {
        
        self.account_id = account_id;
        self.account_name = account_name;
        self.account_type = account_type;
        self.institution_id = institution_id;
        self.institution_name = institution_name;
        self.transaction_date = transaction_date;
        self.transaction_date_as_display = transaction_date_as_display
        self.pending = pending
        self.amount = amount;
        self.display_amount = display_amount;
        self.name = name;
        self.category0 = category0;
        self.category1 = category1;
        self.category2 = category2;
        self.category_display_text = category_display_text;
        self.category_emoji = category_emoji;
        self.address = address;
        self.city = city;
        self.state = state;
        self.zip = zip;
        self.latitude = latitude;
        self.longitude = longitude;
        self.transaction_id = transaction_id;
    }
}

extension TransactionDetails: Mappable {
    
    static func empty() -> TransactionDetails {
        return TransactionDetails(account_id: EMPTY_STRING, account_name: EMPTY_STRING, account_type: EMPTY_STRING, institution_id: EMPTY_STRING, institution_name: EMPTY_STRING, transaction_date: EMPTY_STRING, transaction_date_as_display: EMPTY_STRING, pending: EMPTY_STRING, amount: EMPTY_STRING, display_amount: EMPTY_STRING, name: EMPTY_STRING, category0: EMPTY_STRING, category1: EMPTY_STRING , category2 : EMPTY_STRING, category_display_text: EMPTY_STRING, category_emoji: EMPTY_STRING, address: EMPTY_STRING, city: EMPTY_STRING, state: EMPTY_STRING,  zip: EMPTY_STRING,latitude: EMPTY_STRING, longitude: EMPTY_STRING, transaction_id: EMPTY_STRING)
    }
    
    static func Map(_ json: JSONObject) -> TransactionDetails? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        
        let account_id = (d <-  "account_id") ?? EMPTY_STRING
        let account_name = (d <-  "account_name") ?? EMPTY_STRING
        let account_type = (d <-  "account_type") ?? EMPTY_STRING
        let institution_id = (d <-  "institution_id") ?? EMPTY_STRING
        let institution_name = (d <-  "institution_name") ?? EMPTY_STRING
        let transaction_date = (d <-  "transaction_date") ?? EMPTY_STRING
        var transaction_date_as_display = (d <-  "transaction_date_as_display") ?? EMPTY_STRING
        var pending = (d <- "pending") ?? EMPTY_STRING
        var amount = (d <- "amount") ?? EMPTY_STRING
        var display_amount = (d <- "display_amount") ?? EMPTY_STRING
        let name = (d <- "name") ?? EMPTY_STRING
        let category0 = (d <- "category0") ?? EMPTY_STRING
        let category1 = (d <- "category1") ?? EMPTY_STRING
        let category2 = (d <- "category2") ?? EMPTY_STRING
        var category_display_text = ChatUtils.getCategoryDisplayName(category0, category1, category2)
        var category_emoji = (d <- "category_emoji") ?? EMPTY_STRING
        var address = (d <- "address") ?? EMPTY_STRING
        var city = (d <- "city") ?? EMPTY_STRING
        var state = (d <- "state") ?? EMPTY_STRING
        let zip = (d <- "zip") ?? EMPTY_STRING
        let latitude = (d <- "lat") ?? EMPTY_STRING
        let longitude = (d <- "long") ?? EMPTY_STRING
        let transaction_id = (d <- "transaction_id") ?? EMPTY_STRING
        
        //APIV2.0 Changes
        let displayDate1 = ChatUtils.getDayOfWeek(transaction_date) ?? EMPTY_STRING
        let displayDate2 = ChatUtils.convertToDateString(transaction_date)
        transaction_date_as_display =  displayDate1 + displayDate2
        
        if let amt = d["amount_billing_currency"] as? Double {
            amount = amt.formattedWithSeparator
            display_amount = amt.formattedWithSeparator
        } else if let amt = d["amount_billing_currency"] as? String {
            amount = amt
            display_amount = amt
        }
        
        if display_amount == "", let amt = d["amount"] as?  String {
            display_amount = amt
        }
        
        if let date = d["transaction_date_as_display"] as? String, date != "" {
            transaction_date_as_display = (d <-  "transaction_date_as_display") ?? EMPTY_STRING
        }
        
        if let _pending = d["pending"] as? Int {
            pending = (_pending == 1) ? "true" : "false"
        } else if let _pending = d["pending"] as? String {
            pending = _pending
        }
        
        if let category = d["mcc_details"] as? Dictionary<String, Any> {
            let category0 = (category <- "category_level0") ?? EMPTY_STRING
            let category1 = (category <- "category_level1") ?? EMPTY_STRING
            let category2 = (category <- "category_level2") ?? EMPTY_STRING
            category_emoji = (category <- "category_emoji") ?? EMPTY_STRING
            category_display_text = ChatUtils.getCategoryDisplayName(category0, category1, category2)
        }
        
        if let categoryArray = d["category"] as? Array<String> {
            category_display_text = EMPTY_STRING
            for category in categoryArray {
                category_display_text = category_display_text + (category_display_text.count == 0 ? category : ", " + category1)
            }
        }
        
        if let location = d["location"] as? Dictionary<String, Any> {
            address = (location <- "address") ?? EMPTY_STRING
            city = (location <- "city") ?? EMPTY_STRING
            state = (location <- "state") ?? EMPTY_STRING
        }
        
        
        return TransactionDetails(account_id: account_id, account_name: account_name, account_type: account_type, institution_id: institution_id, institution_name: institution_name, transaction_date: transaction_date, transaction_date_as_display: transaction_date_as_display, pending: pending, amount: amount, display_amount: display_amount, name: name, category0: category0, category1: category1 , category2 : category2, category_display_text: category_display_text, category_emoji: category_emoji, address: address, city: city, state: state,  zip: zip, latitude: latitude, longitude: longitude, transaction_id: transaction_id)
    }
        
}


struct Transactions {
    var transactionDetails: [TransactionDetails] = []
    var suggestions: [Suggestions] = []
    var accounts: [Account] = []
    var cardRecommands: [CardRecommand] = []
    var spendData: [GraphData] = []
}


extension Transactions: Mappable {
    static func empty() -> Transactions {
        return Transactions(transactionDetails: [], suggestions: [], accounts: [], cardRecommands: [], spendData: [])
    }
    
    static func Map(_ json: JSONObject) -> Transactions? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        let transactionDetails: [TransactionDetails] = (d <-- "transactions") ?? []
        let suggestions: [Suggestions] = (d <-- "questionsList") ?? []
        let accounts : [Account] = (d <-- "account_data") ?? []
        let cardRecommands : [CardRecommand] = (d <-- "card_reco_data") ?? []
        let spendData : [GraphData] = (d <-- "graph_data") ?? []
        return Transactions(transactionDetails: transactionDetails, suggestions: suggestions, accounts: accounts, cardRecommands: cardRecommands, spendData: spendData)
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
