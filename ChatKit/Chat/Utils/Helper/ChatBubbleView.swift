//
//  ChatBubbleView.swift
//  ChatKit
//
//  Created by saran on 24/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import UIKit

class ChatBubbleView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
    
    func applyStyle() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        self.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = true
    }
}

class ChatAvatharView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
    
    func applyStyle() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = true
    }
}
