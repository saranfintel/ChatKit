//
//  ChatMessageCollectionViewCell.swift
//  Eva
//
//  Created by saran on 15/12/19.
//  Copyright © 2019 Eva. All rights reserved.
//

import UIKit

open class ChatMessageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var textViewDisplayNotes: UITextView?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var imgView: UIImageView?


    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.borderWidth = 1.0
        bubbleView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        bubbleView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        bubbleView.layer.cornerRadius = 15.0
        bubbleView.layer.masksToBounds = true
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
        textViewDisplayNotes?.isScrollEnabled = true
        self.textViewDisplayNotes?.font = UIFont.systemFont(ofSize: 17.0)//NayaUtils.getFont(of: AppDelegateManager.FONT_REGULAR, of: 17.0)
        self.imgView?.image = UIImage(named: senderImage)

    }
    
    func configureCell(message: ChatDBMessage) {
        textViewDisplayNotes?.textColor = ChatColor.chatDarkTheme()
        dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)

    }

}
