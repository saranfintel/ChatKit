//
//  WelcomeStackView.swift
//  Eva
//
//  Created by saran on 22/06/19.
//  Copyright © 2019 Eva. All rights reserved.
//

import UIKit

class WelcomeStackView: UIView {
    
    @IBOutlet weak var selectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectButton.backgroundColor = ChatColor.appTheme()
    }
    
    @IBAction func selectionButtonClicked(_ sender: Any) {
        if let button = sender as? UIButton, let text = button.currentTitle, let messageDict = ChatMessageDataModel.messagePayloadDictionary(forText: text) {
            ChatMessageDataModel.insertUnsentMessageToDB(fromMessageDetails: messageDict, completionHandler: { (isSuccess, resultt, error) in
            })
        }
    }
}
