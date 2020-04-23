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
    @IBOutlet weak var bubbleView: UIView!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.borderWidth = 1.0
        bubbleView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        bubbleView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        bubbleView.layer.cornerRadius = 15.0
        bubbleView.layer.masksToBounds = true
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
    }
    
}
