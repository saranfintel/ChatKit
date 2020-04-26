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
    @IBOutlet weak var receiverImageview: UIImageView!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        receiverImageview.image = ChatSession.receiveIcon()
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
    }
    
}
