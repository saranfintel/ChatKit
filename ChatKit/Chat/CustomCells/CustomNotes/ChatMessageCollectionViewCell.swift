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
    @IBOutlet weak var bubbleView: ChatBubbleView!
    @IBOutlet weak var textViewDisplayNotes: UITextView?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var receiverImageview: UIImageView!

    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
        textViewDisplayNotes?.isScrollEnabled = true
        self.textViewDisplayNotes?.font = UIFont.systemFont(ofSize: 17.0)
        receiverImageview.image = ChatSession.receiveIcon()
    }
    
    func configureCell(message: ChatDBMessage) {
        textViewDisplayNotes?.textColor = ChatColor.chatDarkTheme()
        dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)

    }

}
