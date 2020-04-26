//
//  ChatDBUpdateOperation.swift
//  ChatApp
//
//  Created by saran on 24/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import CoreData

@objc
protocol DBUpdateOperationDelegate {
    @objc optional func operation(operation: DBUpdateOperation, didCompleteWithResult: [String: AnyObject])
}

class ChatDBUpdateManager: NSObject {
    static let shared = ChatDBUpdateManager()
    var operationQueue = OperationQueue()
    var callback: ((Bool?)->())?
    override init() {
        operationQueue.maxConcurrentOperationCount = 1
        super.init()
    }
}

class DBUpdateOperation: ChatEvaOperation {
    let delegate: DBUpdateOperationDelegate?
    let managedObjectContext: NSManagedObjectContext
    
    var data: AnyObject?
    init(data: AnyObject?, delegate: DBUpdateOperationDelegate?, parentManagedObjectContext: NSManagedObjectContext) {
        
        self.data = data
        self.delegate = delegate
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.managedObjectContext.parent = parentManagedObjectContext
        self.managedObjectContext.undoManager = nil
        super.init()
    }
    
    func saveChanges() {
        managedObjectContext.performAndWait({
            do {
                if self.managedObjectContext.hasChanges {
                    try self.managedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        })
        ChatCoreDataStack.sharedInstance.saveChanges()
    }
}
