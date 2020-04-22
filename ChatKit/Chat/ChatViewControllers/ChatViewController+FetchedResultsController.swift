//
//  ChatViewController+FetchedResultsController.swift
//  ChatApp
//
//  Created by saran on 25/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension ChatViewController: NSFetchedResultsControllerDelegate {
    // MARK: - NSFetchedResultsControllerDelegate methods
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Reload the "load earier cell"
        // When the first message is posted, we need to change the 'empty state cell' to "no earlier messages" cell.
        /*if shouldRefreshLoadEarlierCell == true {
            self.messagesCollectionView.performBatchUpdates({
                let loadMoreIndexPath = IndexPath(row: 0, section: (self.messagesCollectionView.numberOfSections - 1))
                self.messagesCollectionView.reloadItems(at: [loadMoreIndexPath])
                shouldRefreshLoadEarlierCell = false
            })
        }*/
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // Last section in chat view is reserved for Unsent messages
        // So the last section from FRC will be mapped as last but one section
        // This applies for all the other sections from FRC
        var modifiedIndexPath = indexPath
        var modifiedNewIndexPath = newIndexPath
        let readMessageCount = self.fetchedResultsController.sections?.count ?? 0
        if controller == self.fetchedResultsController {
            // Modifying indexpaths - Section mapping to accomodate unsent messages section
            if let _indexPath = indexPath {
                modifiedIndexPath = IndexPath(row: _indexPath.row, section: _indexPath.section)
            }
            if let _newIndexPath = newIndexPath {
                modifiedNewIndexPath = IndexPath(row: _newIndexPath.row, section: _newIndexPath.section)
            }
        } else {
            // Modifying indexpaths - Section for unsent messages
            if let _indexPath = indexPath {
                modifiedIndexPath = IndexPath(row: _indexPath.row, section: readMessageCount)
            }
            if let _newIndexPath = newIndexPath {
                modifiedNewIndexPath = IndexPath(row: _newIndexPath.row, section: readMessageCount)
            }
        }
        switch type {
            // FIXME: there is an issue with FetchedResultsController didChangeObject method sending out wrong ChangeType. And the order of the cases are changed as a work around.
            // We need to check if we can achieve the work around mentioned in the below link
        // Ref : https://developer.apple.com/library/content/releasenotes/iPhone/NSFetchedResultsChangeMoveReportedAsNSFetchedResultsChangeUpdate/
        case NSFetchedResultsChangeType.update:
            // NOTE: Sometimes, while inserting a bunch of messages, we get an extra 'update' event in addition to the 'insert' events.
            // So, to ignore it, we check if the old indexpath and new indexpath are the same before reload the cell
            // If they are different, ignore the change
            if let updateIndexPath = modifiedIndexPath, let updateNewIndexPath = modifiedNewIndexPath, updateIndexPath.row == updateNewIndexPath.row, updateIndexPath.section == updateNewIndexPath.section {
                // Note that for Update, we update the row at __indexPath__
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadItems(at: [updateIndexPath])
                }
            }
        case NSFetchedResultsChangeType.move:
            DispatchQueue.main.async {
                self.messagesCollectionView.moveItem(at: modifiedIndexPath!, to: modifiedNewIndexPath!)
            }
        case NSFetchedResultsChangeType.insert:
            // Note that for Insert, we insert a row at the __newIndexPath__
            if let insertIndexPath = modifiedNewIndexPath {
                let count = self.messagesCollectionView.numberOfItems(inSection: insertIndexPath.section)
                if controller == self.fetchedResultsController {
                    //let numberOfSectionsInDB = self.fetchedResultsController.sections?.count ?? 0
                    let numberOfObjects = self.fetchedResultsController.sections?[insertIndexPath.section].numberOfObjects ?? 0
                    if (count + 1 ==  numberOfObjects) {
                        self.messagesCollectionView.performBatchUpdates({
                            self.messagesCollectionView.insertItems(at: [insertIndexPath])
                        }, completion: { finished in
                            self.messagesCollectionView.scrollToBottom(animated: true)
                        })
                    } else {
                        // Insert multiple rows at a time - executed only at load chat history
                        let indexPaths = (0 ..< numberOfObjects - count).map { IndexPath(row: $0, section: insertIndexPath.section) }
                        if self.fetchedResultsController.fetchedObjects?.count ?? 0 < 20 {
                            self.messagesCollectionView.performBatchUpdates({
                                self.messagesCollectionView.insertItems(at: indexPaths)
                            }, completion: { finished in
                                self.messagesCollectionView.scrollToBottom(animated: false)
                                self.canMakeLoadMoreCall = true
                            })
                        } else {
                            let contentHeight = self.messagesCollectionView.contentSize.height
                            let offsetY = self.messagesCollectionView.contentOffset.y
                            let bottomOffset = contentHeight - offsetY
                            CATransaction.begin()
                            CATransaction.setDisableActions(true)
                            self.messagesCollectionView.performBatchUpdates({
                                self.messagesCollectionView.insertItems(at: indexPaths)
                            }, completion: { finished in
                                //print("completed loading of new stuff, animating")
                                self.messagesCollectionView.contentOffset = CGPoint(x: 0, y: self.messagesCollectionView.contentSize.height - bottomOffset)
                                self.canMakeLoadMoreCall = true
                                CATransaction.commit()
                            })
                        }
                    }
                } else {
                    self.messagesCollectionView.insertItems(at: [insertIndexPath])
                    messagesCollectionView.scrollToBottom(animated: true)
                }
                if controller == self.fetchedResultsController {
                    if modifiedNewIndexPath == IndexPath(row: 0, section: 1) {
                        // When a new message is posted, the first unsent message has to be checked if it can be clubbed with this newly posted message successful
                        if let fetchedObjects = self.unsentMessageFetchedResultsController.fetchedObjects, fetchedObjects.count > 0 {
                            let lastUnsentMessageIndexPath = IndexPath(row: fetchedObjects.count - 1, section: insertIndexPath.section + 1)
                            self.messagesCollectionView.reloadItems(at: [lastUnsentMessageIndexPath])
                        }
                        // If a new ChatDBMessage is inserted, we need to check if it is the only message in tha table(inclusive of both ChatDBMessage and ChatDBUnsentMessage objects). In which case, we have to reload the empty state cell to now show "no earlier messages" cell.
                        let messageObjects = self.fetchedResultsController.fetchedObjects?.count ?? 0
                        let unsentMessageObjects = self.unsentMessageFetchedResultsController.fetchedObjects?.count ?? 0
                        if messageObjects + unsentMessageObjects == 1 {
                            shouldRefreshLoadEarlierCell = true
                        }
                    }
                } else {
                    // If a new ChatDBUnsentMessage is inserted, we need to check if it is the only message in tha table(inclusive of both ChatDBMessage and ChatDBUnsentMessage objects). In which case, we have to reload the empty state cell to now show "no earlier messages" cell.
                    let messageObjects = self.fetchedResultsController.fetchedObjects?.count ?? 0
                    let unsentMessageObjects = self.unsentMessageFetchedResultsController.fetchedObjects?.count ?? 0
                    if messageObjects + unsentMessageObjects == 1 {
                        shouldRefreshLoadEarlierCell = true
                    }
                }
            }
        case NSFetchedResultsChangeType.delete:
            // Note that for Delete, we delete the row at __indexPath__
            if let deleteIndexPath = modifiedIndexPath {
                let count = self.messagesCollectionView.numberOfItems(inSection: deleteIndexPath.section)
                if count >=  deleteIndexPath.row {
                    UIView.performWithoutAnimation {
                        self.messagesCollectionView.deleteItems(at: [deleteIndexPath])
                    }
                }
            }
            let messageObjects = self.fetchedResultsController.fetchedObjects?.count ?? 0
            let unsentMessageObjects = self.unsentMessageFetchedResultsController.fetchedObjects?.count ?? 0
            if messageObjects + unsentMessageObjects == 0 {
                shouldRefreshLoadEarlierCell = true
            }
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let readMessageSectionCount = self.fetchedResultsController.sections?.count ?? 0
        if controller == self.fetchedResultsController {
            let sectionIndexSet = IndexSet(integer: sectionIndex)
            switch type {
            case .insert:
                // Insert multiple sections at a time - executed only at chat history with multiple dates
                let totalRemainingSection = readMessageSectionCount - (self.messagesCollectionView.numberOfSections - 1)
                if totalRemainingSection > 0 {
                    UIView.performWithoutAnimation {
                        self.messagesCollectionView.performBatchUpdates({
                            if sectionIndex < self.messagesCollectionView.numberOfSections {
                                self.messagesCollectionView.reloadSections(sectionIndexSet)
                            }
                            if totalRemainingSection == 1 && sectionIndex > 0 {
                                self.messagesCollectionView.insertSections(sectionIndexSet)
                            } else {
                                self.messagesCollectionView.insertSections(IndexSet(0..<totalRemainingSection))
                            }
                        })
                    }
                }
            case .delete:
                self.messagesCollectionView.deleteSections(sectionIndexSet)
            default:
                break
            }
        } else {
            let sectionIndexSet = IndexSet(integer: readMessageSectionCount)
            switch type {
            case .insert:
                self.messagesCollectionView.insertSections(sectionIndexSet)
            case .delete:
                self.messagesCollectionView.deleteSections(sectionIndexSet)
            default:
                break
            }
        }
    }
}
