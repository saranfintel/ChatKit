//
//  ChatTransactionCollectionViewCell.swift
//  ChatApp
//
//  Created by pooma on 12/23/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import MessageKit

protocol loadMoreTranscationDelegate: class {
    func loadmoreButtonPressed(_ transactionDetails: [TransactionDetails], displayType: String)
}

open class ChatTransactionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var loadMoreHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleView: ChatBubbleView!
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var avatarlabel: ChatLabel!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var loadMoreButton: UIButton?

    var transactionResponse: Transactions? = nil
    var displayType: String = ""
    weak var delegate: loadMoreTranscationDelegate?

    override open func awakeFromNib() {
        super.awakeFromNib()
        setUpViews()
    }
    
    func setUpViews() {
        if let icon = ChatSession.receiveIcon() {
            self.avatarIcon.image = icon
            self.avatarIcon.isHidden = false
        } else {
            self.avatarlabel.text = ChatSession.receiveTitle()
            self.avatarlabel.isHidden = false
        }
        loadMoreButton?.backgroundColor = ChatColor.appTheme()
        self.tableView?.register(UINib(nibName: "ChatTransactionInfoCell", bundle: ChatWorkflowManager.bundle), forCellReuseIdentifier: "ChatTransactionInfoCell")
        self.tableView?.separatorColor = ChatColor.sepertorLineTheme()
    }
    
    func configurationCell(message: ChatDBMessage) {
        guard let transactionsMessage = message.kind else {
            return
        }
        dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)
        transactionResponse = Transactions.Map(transactionsMessage)
        let count = transactionResponse?.transactionDetails.count ?? 0
        loadMoreHeightConstraint.constant = CGFloat(count > 3 ? LOAD_MORE_HEIGHT : 0)
        self.tableView?.reloadData()
    }
    
    @IBAction func loadMoreButtonClicked(_ sender: Any) {
        self.delegate?.loadmoreButtonPressed(transactionResponse?.transactionDetails ?? [], displayType: displayType)
    }
    
    deinit {
        print("ChatAccountCollectionViewCell deinit")
        transactionResponse = nil
    }

}

extension ChatTransactionCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = transactionResponse?.transactionDetails.count ?? 0
        if count > 2 {
            return 3
        }
        return count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView?.dequeueReusableCell(withIdentifier: "ChatTransactionInfoCell") as? ChatTransactionInfoCell, let transactionDetails = transactionResponse?.transactionDetails[indexPath.row] else {
            return UITableViewCell()
        }
        cell.updateCellValues(at: indexPath,transactions: transactionDetails, displayType: displayType)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(CELL_HEIGHT)
    }
}


