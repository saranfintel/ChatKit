//
//  ChatTransactionInfoCell.swift
//  ChatApp
//
//  Created by pooma on 12/23/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit

let CHAT_TRANSACTION_DETAILS = "Transaction Details"

open class ChatTransactionInfoCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var transDetailLabel: UILabel?
    @IBOutlet weak var transcategoryLabel: UILabel?
    @IBOutlet weak var pending_indicatorLabel: UILabel?
    @IBOutlet weak var amtLabel: UILabel?
    @IBOutlet weak var transDetailheaderLabel: UILabel?
    @IBOutlet weak var transDetailheaderImgView: UIImageView?
    @IBOutlet weak var topSeparatorImgView: UIImageView?
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCellValues(at indexPath: IndexPath, transactions: TransactionDetails, displayType: String) {
        topSeparatorImgView?.isHidden = (indexPath.row == 0) ? false : true
        topSeparatorImgView?.backgroundColor = UIColor.colorFromHex(hexString: "#979797")
        dateLabel?.attributedText = ChatUtils.formatPoint8Text(text: transactions.transaction_date_as_display)
        transDetailLabel?.attributedText = ChatUtils.formatPoint8Text(text: transactions.name)
        pending_indicatorLabel?.isHidden = (transactions.pending == "true") ? false : true
        self.setAmount(transactions: transactions)
        self.setCategory(transactions: transactions, displayType: displayType)
        self.setThemeColor()
    }
    
    fileprivate func setCategory(transactions: TransactionDetails, displayType: String) {
        // Display account name, if displayType == messageWithTransaction
        if let displayType: DisplayType = DisplayType(rawValue: displayType) {
            self.backgroundColor = (displayType == .accountTransactions) ? .white : .clear
            switch displayType {
            case .messageWithTransaction:
                transcategoryLabel?.text = transactions.account_name
            default:
                if transactions.category_emoji == "" {
                    transcategoryLabel?.attributedText = ChatUtils.formatPoint8Text(text: transactions.category_display_text.emojiUnescapedString)
                } else {
                    transcategoryLabel?.text = transactions.category_emoji.emojiUnescapedString
                }
            }
        }
    }
    
    fileprivate func setThemeColor() {
        transDetailheaderLabel?.attributedText = ChatUtils.formatPoint8Text(text: CHAT_TRANSACTION_DETAILS)
        dateLabel?.textColor = ChatColor.blackTheme()
        transDetailLabel?.textColor = ChatColor.blackTheme()
        transcategoryLabel?.textColor = ChatColor.blackTheme()
        transDetailheaderLabel?.textColor = ChatColor.blackTheme()
        transDetailheaderImgView?.backgroundColor = ChatColor.blackTheme()
        transDetailLabel?.textColor = ChatColor.blackTheme()
    }
    
    fileprivate func setAmount(transactions: TransactionDetails) {
        if (transactions.display_amount.contains("-")) {
            let amtSignRemoved = transactions.display_amount.replacingOccurrences(of: "-", with: "")
            amtLabel?.attributedText = (amtSignRemoved == "") ? ChatUtils.formatAmountWithFont(amount: "N/A") : ChatUtils.formatAmountWithBoldFont(amount: amtSignRemoved)
            amtLabel?.textColor = ChatColor.blackTheme()
        } else {
            amtLabel?.attributedText = (transactions.display_amount == "") ? ChatUtils.formatAmountWithFont(amount: "N/A") :
                ChatUtils.formatAmountWithFont(amount: transactions.display_amount)
            amtLabel?.textColor = ChatColor.blackTheme()
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    deinit {
        print("ChatTransactionInfoCell Deinit")
    }
}


