//
//  ChatConnectedAccountCell.swift
//  ChatApp
//
//  Created by pooma on 12/23/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit

let CHAT_CURRENT_BALANCE                     =   "Current balance"
let CHAT_AVAILABLE_BALANCE                   =   "Available balance"
let CHAT_PAYOFF_VALUE                        =   "Payoff Value"
let CHAT_UTILIZATION                         =   "Utilization"

let CHAT_CURRENT_BALANCE_COLOR_CODE          =   "#D23246"
let CHAT_AVAILABLE_BALANCE_COLOR_CODE        =   "#3CAD5F"
let CHAT_PAYOFF_COLOR_CODE                   =   "#E26F4A"
let CHAT_BLACK_HEX_COLORCODE                 =   "#000000"

class ChatConnectedAccountCell: UITableViewCell {
    
    var btnClickArray = [String]()
    
    @IBOutlet weak var amountBtn: UIButton?
    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var logoNameLabel: UILabel?
    @IBOutlet weak var accountNameLabel: UILabel?
    @IBOutlet weak var typeofAccountLabel: UILabel?
    @IBOutlet weak var amtLabel: UILabel?
    @IBOutlet weak var balanceTypeLabel: UILabel?
    
    @IBOutlet weak var infoBtn: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAmountButton()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateCellValues(at indexPath: IndexPath, account: Account) {
        
        amountBtn?.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        amountBtn?.setTitle("", for: .normal)
        
            accountNameLabel?.attributedText = ChatUtils.formatStaticText(text: account.official_name == "" ? account.name : account.official_name)
            
            // Amount
            self.setAvailableAmountValue(account: account)
            amountBtn?.tag = indexPath.row
            self.amountBtn?.backgroundColor = UIColor.colorFromHex(hexString: CHAT_AVAILABLE_BALANCE_COLOR_CODE)
            
            // Subtype
            typeofAccountLabel?.attributedText = ChatUtils.formatPoint8Text(text: account.subtype.capitalized)
            
            //Balance Type
            balanceTypeLabel?.attributedText = ChatUtils.formatStaticText(text: CHAT_AVAILABLE_BALANCE)
            
            // For Current Balance
            if self.btnClickArray.index(of:String(indexPath.row)) != nil {
                
                // Amount
                self.setCurrentAmountValue(account: account)
                self.amountBtn?.backgroundColor = UIColor.colorFromHex(hexString: CHAT_CURRENT_BALANCE_COLOR_CODE)
                
                //Balance Type
                balanceTypeLabel?.attributedText = ChatUtils.formatStaticText(text: CHAT_CURRENT_BALANCE)
            }
            
            self.updateDisplayTypeSpecific(account)
            //Logo
            self.setLogoImage(account)
            self.updateTableCell()
            // show reconnect button
            self.showReconnectbutton(account)
    }
    
    func showReconnectbutton(_ account: Account)  {
        let displayType = ChatDataController.sharedInstance.currentDisplayType
        if ( displayType == .accountTransactions && account.is_reconnect_required == "TRUE") {
            self.infoBtn?.isHidden = false
        } else {
            self.infoBtn?.isHidden = true
        }
    }
    
    func updateDisplayTypeSpecific(_ account : Account) {
        let displayType = ChatDataController.sharedInstance.currentDisplayType
        if displayType == .accountsWithOutstandingRed {
            // Amount
            self.setCurrentAmountValue(account: account)
            self.amountBtn?.backgroundColor = UIColor.colorFromHex(hexString: CHAT_CURRENT_BALANCE_COLOR_CODE)
            
            //Balance Type
            balanceTypeLabel?.attributedText = ChatUtils.formatStaticText(text: CHAT_CURRENT_BALANCE)
        }
        
        if displayType == .accountsWithGreen {
            // Amount
            self.setAvailableAmountValue(account: account)
            self.amountBtn?.backgroundColor = UIColor.colorFromHex(hexString: CHAT_AVAILABLE_BALANCE_COLOR_CODE)
            
            //Balance Type
            balanceTypeLabel?.attributedText = ChatUtils.formatStaticText(text: CHAT_AVAILABLE_BALANCE)
        }
        if displayType == .accountsWithPayoffOrange {
            // Amount
            self.setPayoffValue(account: account)
            self.amountBtn?.backgroundColor = UIColor.colorFromHex(hexString: CHAT_PAYOFF_COLOR_CODE)
            
            //Balance Type
            balanceTypeLabel?.attributedText = ChatUtils.formatStaticText(text: CHAT_PAYOFF_VALUE)
        }
        if displayType == .accountsWithUtilizationRed {
            // Amount
            self.setUtilizationValue(account: account)
            self.amountBtn?.backgroundColor = UIColor.colorFromHex(hexString: CHAT_CURRENT_BALANCE_COLOR_CODE)
            
            //Balance Type
            balanceTypeLabel?.attributedText = ChatUtils.formatStaticText(text: CHAT_UTILIZATION)
        }
        // Amount Label Color
        amountBtn?.titleLabel?.textColor = UIColor.colorFromHex(hexString: "#FFFFFF")
    }
    
    
    func setLogoImage(_ account : Account) {
        //TODO: Check With Black image from KG
        let typeName = "_natural"
        let bankImageName = account.institution_id.lowercased() + typeName
        // Logo ImageView
        logoImageView?.image = UIImage.init(named: bankImageName)
        logoImageView?.contentMode = .left
        logoNameLabel?.isHidden = true
        // Display Bank Name, if Bank Logo is not available
        if logoImageView?.image == nil {
            logoNameLabel?.isHidden = false
            logoNameLabel?.text = account.institution_name
        }
    }
    
    func setAvailableAmountValue(account: Account?) {
        // Display N/A, if amount is not available
        if account?.available_balance != "" && account?.available_balance != "%" {
            let amountObj = ChatSession.currencySymbol() + (account?.available_balance ?? EMPTY_STRING)
            let amount = ChatUtils.formatAmount(amount: amountObj)
            amountBtn?.setAttributedTitle(amount, for: .normal)
        } else {
            if account?.subtype.lowercased() == "credit card" || account?.subtype.lowercased() == "loan" || account?.subtype.lowercased() == "line of credit" {
                let amount = ChatUtils.formatAmount(amount: "Unavailable")
                amountBtn?.setAttributedTitle(amount, for: .normal)
            } else {
                let amount = ChatUtils.formatAmount(amount: "N/A")
                amountBtn?.setAttributedTitle(amount, for: .normal)
            }
        }
    }
    
    func setPayoffValue(account: Account?) {
        // Display N/A, if amount is not available
        if account?.payoff_value != "" {
            let amount = ChatUtils.formatAmount(amount: account?.payoff_value ?? "")
            amountBtn?.setAttributedTitle(amount, for: .normal)
        } else {
            let amount = ChatUtils.formatAmount(amount: "Unavailable")
            amountBtn?.setAttributedTitle(amount, for: .normal)
        }
    }
    
    func setCurrentAmountValue(account: Account?) {
        // Display N/A, if amount is not available
        if account?.current_balance != "" && account?.current_balance != "%" {
            let amountObj = ChatSession.currencySymbol() + (account?.current_balance ?? EMPTY_STRING)
            let amount = ChatUtils.formatAmount(amount: amountObj)
            amountBtn?.setAttributedTitle(amount, for: .normal)
        } else {
            if account?.subtype.lowercased() == "credit card" || account?.subtype.lowercased() == "loan" || account?.subtype.lowercased() == "line of credit" {
                let amount = ChatUtils.formatAmount(amount: "Unavailable")
                amountBtn?.setAttributedTitle(amount, for: .normal)
            } else {
                let amount = ChatUtils.formatAmount(amount: "N/A")
                amountBtn?.setAttributedTitle(amount, for: .normal)
            }
        }
    }
    
    func setUtilizationValue(account: Account?) {
        // Display N/A, if utilization is not available
        if account?.utilization_percent_as_text != "" && account?.utilization_percent_as_text != "%" {
            let amount = ChatUtils.formatAmount(amount: account?.utilization_percent_as_text ?? "")
            self.amountBtn?.setAttributedTitle(amount, for: .normal)
        } else {
            if account?.subtype.lowercased() == "credit card" || account?.subtype.lowercased() == "loan" || account?.subtype.lowercased() == "line of credit" {
                let amount = ChatUtils.formatAmount(amount: "Unavailable")
                amountBtn?.setAttributedTitle(amount, for: .normal)
            } else {
                let amount = ChatUtils.formatAmount(amount: "N/A")
                amountBtn?.setAttributedTitle(amount, for: .normal)
            }
        }
    }
    
    func setAmountButton() {
        amountBtn?.backgroundColor = UIColor.colorFromHex(hexString: CHAT_AVAILABLE_BALANCE_COLOR_CODE)
        self.amountBtn?.setTitleColor(UIColor.white, for: UIControl.State.normal)
        amountBtn?.layer.cornerRadius = 5.0
    }
    
    // Update UITableCell Bg based on Display Type
    func updateTableCell() {
        let displayType = ChatDataController.sharedInstance.currentDisplayType
        self.backgroundColor = UIColor.clear
        
        if displayType == .accountTransactions {
            accountNameLabel?.textColor = UIColor.colorFromHex(hexString:CHAT_BLACK_HEX_COLORCODE)
            typeofAccountLabel?.textColor = UIColor.colorFromHex(hexString: "#4A4A4A")
            balanceTypeLabel?.textColor = UIColor.colorFromHex(hexString:CHAT_BLACK_HEX_COLORCODE)
        } else {
            accountNameLabel?.textColor = UIColor.colorFromHex(hexString:CHAT_BLACK_HEX_COLORCODE)
            typeofAccountLabel?.textColor = UIColor.colorFromHex(hexString: "#4A4A4A")
            balanceTypeLabel?.textColor = UIColor.colorFromHex(hexString:CHAT_BLACK_HEX_COLORCODE)
        }
        accountNameLabel?.textColor = UIColor.colorFromHex(hexString:CHAT_BLACK_HEX_COLORCODE)
        typeofAccountLabel?.textColor = UIColor.colorFromHex(hexString: "#4A4A4A")
        balanceTypeLabel?.textColor = UIColor.colorFromHex(hexString:CHAT_BLACK_HEX_COLORCODE)
    }
}
