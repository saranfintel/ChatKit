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
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var avatarlabel: ChatLabel!

    override open func awakeFromNib() {
        super.awakeFromNib()
        if let icon = ChatSession.receiveIcon() {
            self.avatarIcon.image = icon
            self.avatarIcon.isHidden = false
        } else {
            self.avatarlabel.text = ChatSession.receiveTitle()
            self.avatarlabel.isHidden = false
        }
        // Initialization code
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
        textViewDisplayNotes?.isScrollEnabled = true
        self.textViewDisplayNotes?.font = UIFont.systemFont(ofSize: 17.0)
    }
    
    func configureCell(message: ChatDBMessage) {
        textViewDisplayNotes?.attributedText = ChatUtils.stringMediumFontFromHtml(string: message.displayNotes?.emojiUnescapedString ?? "")
        textViewDisplayNotes?.textColor = ChatColor.chatDarkTheme()
        dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)
    }

}
