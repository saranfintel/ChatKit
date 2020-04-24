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
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
    }
    
}
