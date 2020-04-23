//
//  ChatDBMessage+CoreDataClass.swift
//  ChatApp
//
//  Created by saran on 24/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import CoreData


public class ChatDBMessage: NSManagedObject {
    // Since we are not able to map a optional scalar type as @NSManaged type to entity, we are adding custom getters and setters
    @objc var sectionTitle : String {
        guard let date = self.postedAt else {
            return ""
        }
        let dateString = currentDateFormatterWithFormat().string(from: date as Date)
        return dateString
    }
    
    
    func currentDateFormatterWithFormat() -> Foundation.DateFormatter {
        let threadDictionary: NSMutableDictionary = Thread.current.threadDictionary
        var dateFormatter: Foundation.DateFormatter? = threadDictionary.object(forKey: "DateFormatter") as? Foundation.DateFormatter
        if dateFormatter == nil {
            dateFormatter = Foundation.DateFormatter()
            dateFormatter!.dateFormat = "EEEE, MMM dd, yyyy"
            threadDictionary.setObject(dateFormatter!, forKey: "DateFormatter" as NSCopying)
        }
        return dateFormatter!
    }
}
