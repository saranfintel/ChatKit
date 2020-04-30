//
//  ChatViewController+LoadMore.swift
//  Eva
//
//  Created by saran on 22/12/19.
//  Copyright © 2019 Eva. All rights reserved.
//

import UIKit


extension ChatViewController {
    //MARK:- Load Earlier Messages
    @objc func loadMoreMessages() {
        print("loadMoreMessages")
        DispatchQueue.main.async {
            guard let fetchedObjects = self.fetchedResultsController.fetchedObjects else {
                // Do Refreshing and Set messgae Offet
                self.messagesCollectionView.reloadDataAndKeepOffset()
                return
            }
            // Increase the fetch limit to load more messsages by kMessageThreshold
            self.fetchLimit = fetchedObjects.count + kMessageThreshold
            let totalCount = ChatCoreDataManager.getTotalCountOfSentMessages(context: ChatCoreDataStack.sharedInstance.mainManagedObjectContext) ?? 0
            if totalCount != 0 {
                if totalCount - self.fetchLimit < 20 {
                    self.fetchedResultsController.fetchRequest.fetchLimit = totalCount
                    self.fetchedResultsController.fetchRequest.fetchOffset = 0
                    self.canMakeLoadMoreCall = false
                } else {
                    self.fetchedResultsController.fetchRequest.fetchLimit = self.fetchLimit
                    self.fetchedResultsController.fetchRequest.fetchOffset = totalCount - self.fetchLimit
                }
            }
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                print("fetch error: \(error)")
            }
            guard let newlyFetchedObjects = self.fetchedResultsController.fetchedObjects else {
                // Do Refreshing and Set messgae Offet
                self.messagesCollectionView.reloadDataAndKeepOffset()
                return
            }
            // If the new fetch yields less number of messages than required, check if the user/channel has no more messages.
            // If yes, show "no eralier messages"
            // else fetch from server
            if newlyFetchedObjects.count < self.fetchLimit, self.isFetchingEarlierMessages == false {
                // fetch from server
                var messageID: Int16? = nil
                if let earliestMessageID = ChatCoreDataManager.getEarliestMessageIDOnUserDM(context: ChatCoreDataStack.sharedInstance.mainManagedObjectContext) {
                    messageID = earliestMessageID
                }
                ChatMessageDataModel.listMessagesHandler(messageID: messageID, completionStatusHandler: { (isSuccess) in
                    print("isSuccess earliestMessageID")
                    DispatchQueue.main.async {
                        sleep(1)
                        // Do Refreshing and Set messgae Offet
                        self.refreshControl.endRefreshing()
                        self.messagesCollectionView.reloadDataAndKeepOffset()
                        if isSuccess == false {
                            self.isFetchingEarlierMessages = true
                            self.canMakeLoadMoreCall = false
                            return
                        }
                    }
                })
            } else {
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.messagesCollectionView.performBatchUpdates(nil, completion: { (result) in
                    if totalCount != newlyFetchedObjects.count {
                        self.canMakeLoadMoreCall = true
                    }
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                })
            }
            // Do Refreshing and Set messgae Offet
            self.messagesCollectionView.reloadDataAndKeepOffset()
        }
    }

}

extension ChatViewController: CountrySaveActionDelegate {
    func saveButtonPressed() {
        chatViewModel?.saveSelectedLanguage()
        changeLanguageButton.title = chatViewModel?.selectedLanguage.initial
    }
}
extension ChatViewController: loadMoreAccountsDelegate {
    func loadmoreButtonPressed(_ accounts: [Account]) {
        if let accountsVC = VCNames.accountsVC.controllerObject as? AccountsViewController {
            accountsVC.accounts = accounts
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.navigationController?.pushViewController(accountsVC, animated: true)
        }
    }
}

extension ChatViewController: loadMoreTranscationDelegate {
    func loadmoreButtonPressed(_ transactionDetails: [TransactionDetails], displayType: String) {
        if let transactionsVC = VCNames.transactionsVC.controllerObject as? TranscationsViewController {
            transactionsVC.transactionDetails = transactionDetails
            transactionsVC.displayType = displayType
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(transactionsVC, animated: true)
        }
    }
}
extension ChatViewController {
    func hitDB(body: String, queryType: QueryType = .textSearch) {
        /*var output = ("", [String: Any](), "")
        var queryString = body  // "الرصيد المتوفر"//
        self.showActivityView()
        let delayTime = DispatchTime.now() + .milliseconds(2)//+ Double(0.001)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            queryString = queryString.replacingOccurrences(of:"\'", with: "", options:.literal, range: nil)
            
                NayaAPIWebserviceManager.sharedManager.getUserQuery(self, queryString, queryType, completionHandler: { (status, object, errorMessage) -> Void in
                    DispatchQueue.main.async(execute: {
                        output = (status, object, errorMessage)
                        self.pushToTransactionDetails(responseString: output.1)
                    })
                })
        }*/
    }
    
}
