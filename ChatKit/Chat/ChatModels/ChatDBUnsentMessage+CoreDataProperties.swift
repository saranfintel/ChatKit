//
//  ChatDBUnsentMessage+CoreDataProperties.swift
//  ChatApp
//
//  Created by saran on 24/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import CoreData

extension ChatDBUnsentMessage {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatDBUnsentMessage> {
        return NSFetchRequest<ChatDBUnsentMessage>(entityName: "ChatDBUnsentMessage");
    }
    
    @NSManaged public var body: String?
    @NSManaged public var clientTempID: Double
    @NSManaged public var userID: Int16
    @NSManaged public var noOfRetry: Int16
    @NSManaged public var status: Int16
    @NSManaged public var postedAt: NSDate?
}
