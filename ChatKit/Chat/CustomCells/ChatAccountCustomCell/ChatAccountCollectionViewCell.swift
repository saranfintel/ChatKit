//
//  ChatAccountCollectionViewCell.swift
//  ChatApp
//
//  Created by pooma on 12/23/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import MessageKit

protocol loadMoreActionDelegate: class {
  func loadmoreButtonPressed(_ cell: UICollectionViewCell)
}

open class ChatAccountCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var loadMoreHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var avatarlabel: ChatLabel!
    @IBOutlet weak var receiverImageview: UIImageView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleView: ChatBubbleView!
    @IBOutlet weak var loadMoreButton: UIButton!
    
    var transactionResponse: Transactions? = nil
    weak var delegate: loadMoreActionDelegate?

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
        self.tableView?.register(UINib(nibName: "ChatConnectedAccountCell", bundle: ChatWorkflowManager.bundle), forCellReuseIdentifier: "ChatConnectedAccountCell")
        self.tableView?.separatorColor = UIColor.colorFromHex(hexString: "#eaeaea")
        self.loadMoreButton.backgroundColor = ChatColor.appTheme()
    }
    
    func configurationCell(message: ChatDBMessage) {
        guard let transactionsMessage = message.kind else {
            return
        }
        dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)
        transactionResponse = Transactions.Map(transactionsMessage)
        let count = transactionResponse?.accounts.count ?? 0
        self.tableView?.reloadData()
        loadMoreHeightConstraint.constant = CGFloat(count > 3 ? 40 : 0)
    }
    
    @IBAction func loadMoreButtonClicked(_ sender: Any) {
        self.delegate?.loadmoreButtonPressed(self)
    }
    
    deinit {
        print("ChatAccountCollectionViewCell deinit")
        delegate = nil
        transactionResponse = nil
    }
}

extension ChatAccountCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = transactionResponse?.accounts.count ?? 0
        if count > 2 {
            return 3
        }
        return count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView?.dequeueReusableCell(withIdentifier: "ChatConnectedAccountCell") as? ChatConnectedAccountCell, let account = transactionResponse?.accounts[indexPath.row] else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.updateCellValues(at: indexPath, account: account)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
}

