//
//  ChatViewController+CollectionViewDataSource.swift
//  ChatApp
//
//  Created by saran on 25/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import MessageKit
import CoreData
import InputBarAccessoryView

extension ChatViewController: MessagesDataSource {
        
    func currentSender() -> SenderType {
        return currentUser()
    }
    
    func anotherSender() -> SenderType {
        return anotherUser()
    }
    
    func currentUser() -> MockUser {
        return MockUser(senderId: "000000", displayName: ChatSession.senderTitle())
    }
    
    func anotherUser() -> MockUser {
        return MockUser(senderId: "000001", displayName: ChatSession.receiveTitle())
    }
    
    func getAvatarFor(sender: SenderType) -> Avatar {
        let initials = sender.displayName
        switch sender.senderId {
        case "000000":
            return Avatar(image: ChatSession.senderIcon(), initials: initials)
        case "000001":
            return Avatar(image: ChatSession.receiveIcon(), initials: initials)
        default:
            return Avatar(image: nil, initials: initials)
        }
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        let count = 1 // Add a section for unsent messages
        if let sections = self.fetchedResultsController.sections, sections.count > 0 {
            return sections.count + 1
        }
        return count
    }
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        let readMessageCount = self.fetchedResultsController.sections?.count ?? 0
        let unreadMessageCount = self.unsentMessageFetchedResultsController.sections?.count ?? 0
        if section < readMessageCount {
            let info = self.fetchedResultsController.sections?[section]
            return info?.numberOfObjects ?? 0
        } else if section < (readMessageCount + unreadMessageCount) {
            if let sections = self.unsentMessageFetchedResultsController.sections, sections.count > 0 {
                return sections[0].numberOfObjects
            }
        }
        return 0
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let readMessageCount = self.fetchedResultsController.sections?.count ?? 0
        let unreadMessageCount = self.unsentMessageFetchedResultsController.sections?.count ?? 0
        // let currentUser = SampleData.shared.currentSender
        
        if indexPath.section < readMessageCount {
            guard let sentMessage = self.fetchedResultsController.object(at: indexPath) as? ChatDBMessage else {
                // let message = MockMessage(text: "EMPTY MESSAGE", user: currentUser, messageId: UUID().uuidString, date: Date())
                
                let message = MockMessage(text: "EMPTY MESSAGE", user: anotherSender() as? MockUser ?? anotherUser(), messageId: UUID().uuidString, date: Date())
                
                return message
            }
            let postedAt = sentMessage.postedAt as Date? ?? Date()
            if (sentMessage.kind != nil) || sentMessage.mediaType == "gif" {
                let message = MockMessage(custom: sentMessage, user: anotherSender() as? MockUser ?? anotherUser(), messageId: UUID().uuidString, date: postedAt)
                return message
            } else if let body = sentMessage.body {
                switch body {
                case let type where type.contains(".mov"):
                    if let bundle = Bundle.main.url(forResource: "chatuser", withExtension: "png"), let imageData = try? Data(contentsOf: bundle) {
                        let thumbnailImage = UIImage.init(data: imageData)
                        return MockMessage(thumbnail: thumbnailImage ?? UIImage(), user: anotherSender() as? MockUser ?? anotherUser(), messageId: UUID().uuidString, date: postedAt)
                    }
                case let type where type.contains("emoji"):
                    let imageNameArray = body.components(separatedBy: ".")
                    if imageNameArray.count >= 2 {
                        return MockMessage(emoji: emojis[imageNameArray[0]] ?? "😃😃😃", user: anotherSender() as? MockUser ?? anotherUser(), messageId: UUID().uuidString, date: postedAt)
                    }
                default:
                    return MockMessage(text: body, user: (sentMessage.userID == 1) ? currentSender() as? MockUser ?? currentUser() : anotherSender() as? MockUser ?? anotherUser(), messageId: UUID().uuidString, date: postedAt)
                }
            }
        } else if indexPath.section < (readMessageCount + unreadMessageCount) {
            let modifiedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - readMessageCount)
            if modifiedIndexPath.section < unreadMessageCount {
                let unsentMessage = self.unsentMessageFetchedResultsController.object(at: modifiedIndexPath)
                let messageVar: [String: AnyObject] = unsentMessage.payload()
                if let body = messageVar["query_txt"] as? String {
                    let message = MockMessage(text: body, user: currentSender() as? MockUser ?? currentUser(), messageId: UUID().uuidString, date: Date())
                    return message
                }
            }
        }
        let message = MockMessage(text: "EMPTY MESSAGE", user: anotherSender() as? MockUser ?? anotherUser(), messageId: UUID().uuidString, date: Date())
        return message
    }
}
