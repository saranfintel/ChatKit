//
//  ChatConstant.swift
//  ChatKit
//
//  Created by saran on 21/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation
import CoreData
import UIKit

//MARK:- Chat
let KEY_LAUNCH_TYPE                                       =   "launchType"
let LAUNCH_TYPE_INSIGHTS                                  =   "insights"
let KEY_SESSIONTOKEN                                      =   "SessionToken"
let userImage   = "KrishUser"
let senderImage = "splash"
let timeFormat   =  "h:mm a"
let messageCount = "messageCount"
let voiceLanguage = "voiceLanguage"
let App_Group_ID = "group.com.fintellabs.eva"
let chatWidthSpaces: CGFloat = 65.0
let timeoutForSendingMessages = 15.0
let kMessageThreshold = 20
let kTimeDifferenceAllowedForClubbingMessages : TimeInterval = 120
let kLoadingCellTag = 200

typealias FetchCompletionHandler = (_ object: NSManagedObject?) -> Void
typealias FetchObjectsCompletionHandler = (_ object: [NSManagedObject]?) -> Void
typealias ChatCompletionHandler = (_ success: Bool, _ result: Any?, _ error: NSError?) -> Void
typealias CompletionStatusHandler = (_ success: Bool) -> Void

enum MessageStatus : Int {
    case Published = 1 // 1
    case Sending = 98 // 98
    case Failed = 99 // 99
}
enum MessageUpdateOperationTypes {
    case DetailsUpdate
    case CopyUnsentMessage
    case OtherAttributeUpdate
    case ListMessagesUpdate
    case MessageUpdate
    case BatchUpdate
}
enum UnsentMessageUpdateOperationTypes {
    case DetailsUpdate
    case OtherAttributeUpdate
    case ObjectDelete
}
enum DisplayType: String {
    case messageWithAmountTransactions  =   "message_amount_transactions"
    case messageWithGraphTransactions   =   "message_graph_transactions"
    case messageWithBarTransactions     =   "message_bar_transactions"
    case messageWithPieTransactions     =   "message_pie_transactions"
    case accountTransactions            =   "account_transactions"
    case messageWithTransaction         =   "message_transaction"
    case cardRecommendation             =   "card_view"
    case message                        =   "message"
    case messageWithAmount              =   "message_amount"
    case messageWithNotes               =   "message_notes"
    case messageWithGraph               =   "message_graph"
    case messageWithChart               =   "message_barchart"
    case messageWithPieChart            =   "message_piechart"
    case messageWithError               =   "message_error"
    case accountsWithOutstandingRed     =   "accounts_ored"
    case accountsWithUtilizationRed     =   "accounts_ured"
    case accountsWithGreen              =   "accounts_green"
    case accountsWithPayoffOrange       =   "accounts_porange"
    case verticalQuestions              =   "vertical_questions"
    case horizontalQuestions            =   "horizontal_questions"
}
enum QueryType: String {
    case voiceSearch            =   "voiceSearch"
    case textSearch             =   "textSearch"
    case insights               =   "insights"
    case defaultQuestion        =   "default_question"
    case recentSearch           =   "recentSearch"
    case accountSearch          =   "accountSearch"
    case transactionDetails     =   "transactionDetails"
    case totalBalance           =   "totalBalance"
    
    case validatePasscode       =   "validatePasscode"
    case createEvaUser          =   "createEvaUser"
    case validateEvaUser        =   "validateEvaUser"
    case getUserSettings        =   "getUserSettings"
    case updateUserSettings     =   "updateUserSettings"
    
    case getVersionInfo         =   "getVersionSpecificInfo"
    case recordUserSession      =   "recordUserSession"
    case deleteAccount          =   "delete_account"
    case deleteUser             =   "delete_eva_account"
}

public let EMPTY_STRING = ""
public let NULL_STRING = "null"
public let EMPTY_INT = 0
