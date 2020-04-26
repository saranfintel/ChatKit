//
//  ChatDBMessage+CoreDataProperties.swift
//  ChatApp
//
//  Created by saran on 24/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import CoreData


extension ChatDBMessage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatDBMessage> {
        return NSFetchRequest<ChatDBMessage>(entityName: "ChatDBMessage");
    }
    @NSManaged public var body: String?
    @NSManaged public var userID: Int16
    @NSManaged public var messageId: Int16
    @NSManaged public var postedAt: NSDate?
    @NSManaged public var status: NSNumber?
    @NSManaged public var clientTempID: Double
    @NSManaged public var kind: [String : Any]?
    @NSManaged public var displayType: String?
    @NSManaged public var mediaType: String?
    @NSManaged public var mediaURL: String?
    @NSManaged public var displayNotes: String?
    @NSManaged public var canShowSuggestions: Bool
    @NSManaged public var chatWidth: Double
    @NSManaged public var chatHeight: Double
    
}
