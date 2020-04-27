//
//  ChatLabel.swift
//  ChatKit
//
//  Created by saran on 26/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import UIKit

class ChatLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
    
    func applyStyle() {
        self.backgroundColor = .gray
        self.font = UIFont.systemFont(ofSize: ChatSession.fontSize())
        self.textColor = .white
        self.textAlignment = .center
    }

}
