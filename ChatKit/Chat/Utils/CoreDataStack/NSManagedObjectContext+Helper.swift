//
//  NSManagedObjectContext+Helper.swift
//  Eva
//
//  Created by saran on 15/12/19.
//  Copyright © 2019 Eva. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
     func deleteAllDBObjects() {
        if let entitesByName = persistentStoreCoordinator?.managedObjectModel.entitiesByName {
            for (name, _) in entitesByName {
                deleteAllObjectsForEntity(entityName: name)
            }
        }
    }
    
    func deleteAllObjectsForEntity(entityName: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeCount
        do {
            // Execute Batch Request
            let batchDeleteResult = try ChatCoreDataStack.sharedInstance.mainManagedObjectContext.execute(batchDeleteRequest) as! NSBatchDeleteResult
            print("The batch delete request has deleted \(batchDeleteResult.result!) records.")
            ChatCoreDataStack.sharedInstance.reset()
        } catch {
            let updateError = error as NSError
            print("\(updateError), \(updateError.userInfo)")
        }
    }
}
