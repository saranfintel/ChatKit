//
//  EvaInsetLabel.swift
//  Eva
//
//  Created by Poomalai on 4/16/17.
//  Copyright © 2017 Eva. All rights reserved.
//

import UIKit

class EvaLeftInsetLabel: UILabel {
    var topInset = CGFloat(0)
    var bottomInset = CGFloat(0)
    var leftInset = CGFloat(16)
    var rightInset = CGFloat(0)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        // Swift 4.2
        //super.drawText(in: rect.inset(by:insets))
        //Swift 4.0
        super.drawText(in: rect.inset(by: insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}


class EvaRightInsetLabel: UILabel {
    var topInset = CGFloat(0)
    var bottomInset = CGFloat(0)
    var leftInset = CGFloat(0)
    var rightInset = CGFloat(16)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        // Swift 4.2
        //super.drawText(in: rect.inset(by:insets))
        //Swift 4.0
        super.drawText(in: rect.inset(by: insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}

