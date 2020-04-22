//
//  ChatCoreDataManager.swift
//  ChatApp
//
//  Created by saran on 24/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation
import CoreData


class ChatCoreDataManager {
    fileprivate class func DBMessageFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        // Creating fetch request for ChatDBMessage entity
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        if #available(iOS 10.0, *) {
            fetchRequest = ChatDBMessage.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatDBMessage")
        }
        return fetchRequest
    }
    fileprivate class func DBUnsentMessageFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        // Creating fetch request for ChatDBUnsentMessage entity
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        if #available(iOS 10.0, *) {
            fetchRequest = ChatDBUnsentMessage.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatDBUnsentMessage")
        }
        return fetchRequest
    }
    class func getUnsentMessage(withClientTempID clientTempID: Double, context: NSManagedObjectContext, completionHandler: @escaping FetchCompletionHandler) {
        // Create fetch request for ChatDBUnsentMessage entity
        let fetchRequest = DBUnsentMessageFetchRequest()
        // Configure fetch Request
        fetchRequest.predicate = NSPredicate(format: "clientTempID == %lf", clientTempID)
        fetchRequest.fetchLimit = 1
        // Perform fetch
        do {
            if let fetchedResults: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchedResults.count > 0 {
                    completionHandler(fetchedResults[0])
                } else {
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        } catch {
            print(error)
            completionHandler(nil)
        }
    }
    class func getUnsentMessage(withID id: Int16, context: NSManagedObjectContext) -> NSManagedObject? {
        // Create fetch request for ChatDBUnsentMessage entity
        let fetchRequest = DBUnsentMessageFetchRequest()
        // Configure fetch Request
        fetchRequest.predicate = NSPredicate(format: "messageId == %d", id)
        fetchRequest.fetchLimit = 1
        // Perform fetch
        do {
            if let fetchedResults: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchedResults.count > 0 {
                    return fetchedResults[0]
                }
            }
        } catch {
            print(error)
        }
        return nil
    }
    class func getMessageWithID(_ id: Int16, context: NSManagedObjectContext, completionHandler: @escaping FetchCompletionHandler) {
        // Create fetch request for ChatDBMessage entity
        let fetchRequest = DBMessageFetchRequest()
        // Configure fetch Request
        fetchRequest.predicate = NSPredicate(format: "messageId == %d", id)
        fetchRequest.fetchLimit = 1
        // Perform fetch
        do {
            if let fetchedResults: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchedResults.count > 0 {
                    completionHandler(fetchedResults[0])
                } else {
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        } catch {
            print(error)
            completionHandler(nil)
        }
    }
    class func getMessageWithID(_ id: Int16, context: NSManagedObjectContext) -> NSManagedObject? {
        // Create fetch request for ChatDBMessage entity
        let fetchRequest = DBMessageFetchRequest()
        // Configure fetch Request
        fetchRequest.predicate = NSPredicate(format: "messageId == %d", id)
        fetchRequest.fetchLimit = 1
        // Perform fetch
        do {
            if let fetchedResults: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchedResults.count > 0 {
                    return fetchedResults[0]
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    class func getAllUnsentMessagesForRetry(context: NSManagedObjectContext) -> [ChatDBUnsentMessage]? {
        // Create fetch request for ChatDBUnsentMessage entity
        let fetchRequest = DBUnsentMessageFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "status == %d || status == %d ", Int16(MessageStatus.Sending.rawValue), Int16(MessageStatus.Failed.rawValue))
        let sortDescriptor = NSSortDescriptor(key: "clientTempID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            // forming the unsentMessage dictionary from NSManagedObject manually.
            // Since NULL values for Int field comes as 0 with result type "dictionaryResultType"
            if let fetchedResults: [ChatDBUnsentMessage] = try context.fetch(fetchRequest) as? [ChatDBUnsentMessage] {
                return fetchedResults
            }
        } catch {
            print(error)
        }
        return nil
    }
    //MARK:- Get first message id of the channel
    class func getEarliestMessageIDOnUserDM(context: NSManagedObjectContext) -> Int16? {
        // Create fetch request for ChatDBMessage entity
        let fetchRequest = DBMessageFetchRequest()
        // Configure fetch Request
        fetchRequest.predicate = NSPredicate(format: "status == %d", MessageStatus.Published.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "messageId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        // Perform fetch
        do {
            if let fetchedResults: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchedResults.count > 0 {
                    if let earliestMessage = fetchedResults[0] as? ChatDBMessage {
                        return earliestMessage.messageId
                    }
                }
            }
        } catch {
            print(error)
        }
        return nil
    }
    class func getTotalCountOfSentMessages(context: NSManagedObjectContext) -> Int? {
        // Create fetch request for ChatDBMessage entity
        let fetchRequest = DBMessageFetchRequest()
        // Configure fetch Request
        fetchRequest.predicate = NSPredicate(format: "status == %d", MessageStatus.Published.rawValue)
        // Perform fetch
        do {
            if let fetchedResults: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                return fetchedResults.count
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    class func getSuggestionQuestionObjects(context: NSManagedObjectContext, completionHandler: @escaping FetchObjectsCompletionHandler) {
        // Create fetch request for DBMessage entity
        let fetchRequest = DBMessageFetchRequest()
        // Configure fetch Request
        fetchRequest.predicate = NSPredicate(format: "canShowSuggestions == %@", NSNumber(value: true))
        // Perform fetch
        do {
            if let fetchedResults: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchedResults.count > 0 {
                    completionHandler(fetchedResults)
                } else {
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        } catch {
            completionHandler(nil)
        }
    }
}
