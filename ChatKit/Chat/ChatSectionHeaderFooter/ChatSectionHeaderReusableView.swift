//
//  SectionHeaderReusableView.swift
//  ChatApp
//
//  Created by Sarankumar on 29/04/19.
//  Copyright © 2019 Saran. All rights reserved.
//

import UIKit

open class ChatSectionHeaderReusableView: UICollectionReusableView {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
