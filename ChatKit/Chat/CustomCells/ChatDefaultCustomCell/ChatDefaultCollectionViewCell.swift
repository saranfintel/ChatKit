//
//  ChatDefaultCollectionViewCell.swift
//  ChatApp
//
//  Created by saran on 27/05/19.
//  Copyright © 2019 Saran. All rights reserved.
//

import UIKit
import MessageKit

open class ChatDefaultCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleView: ChatBubbleView!
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
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
    }
    
}
