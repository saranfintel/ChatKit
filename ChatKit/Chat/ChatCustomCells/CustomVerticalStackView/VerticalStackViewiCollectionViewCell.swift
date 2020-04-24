//
//  VerticalStackViewiCollectionViewCell.swift
//  Eva
//
//  Created by saran on 21/06/19.
//  Copyright © 2019 Eva. All rights reserved.
//

import UIKit

open class VerticalStackViewiCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleView: ChatBubbleView!
//    var transactionResponse: Transactions? = nil
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var imgView: UIImageView?


    override open func awakeFromNib() {
        super.awakeFromNib()
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
        self.imgView?.image = UIImage.init(named: senderImage, in: ChatWorkflowManager.bundle, compatibleWith: nil)
    }

    func configureCell(message: ChatDBMessage) {
        /*if transactionResponse == nil {
            guard let transactionsMessage = message.kind, message.canShowSuggestions else {
                return
            }
            dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)
            transactionResponse = Transactions.Map(transactionsMessage)
            guard let suggestions = transactionResponse?.suggestions, suggestions.count > 0, message.canShowSuggestions  else {
                return
            }
            for index in 0..<suggestions.count {
                if let welcomeStackView = Bundle.main.loadNibNamed("WelcomeStackView", owner: nil, options: nil)!.first as? WelcomeStackView {
                    welcomeStackView.selectButton.setTitle(suggestions[index].question, for: .normal)
                    welcomeStackView.widthAnchor.constraint(equalToConstant: stackView.frame.height).isActive = true
                    self.stackView.addArrangedSubview(welcomeStackView)
                }
            }
            self.stackView.layoutIfNeeded()
        }*/
    }
    
    deinit {
        //transactionResponse = nil
    }
    
}
