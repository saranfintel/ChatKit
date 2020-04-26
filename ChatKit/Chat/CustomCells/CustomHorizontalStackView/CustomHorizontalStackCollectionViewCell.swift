//
//  CustomHorizontalStackCollectionViewCell.swift
//  Eva
//
//  Created by saran on 22/06/19.
//  Copyright © 2019 Eva. All rights reserved.
//

import UIKit

open class CustomHorizontalStackCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleView: ChatBubbleView!
    @IBOutlet weak var bubbleLabel: UILabel!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var avatarlabel: ChatLabel!

    var transactionResponse: Transactions? = nil

    override open func awakeFromNib() {
        super.awakeFromNib()
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
        if let icon = ChatSession.receiveIcon() {
            self.avatarIcon.image = icon
            self.avatarIcon.isHidden = false
        } else {
            self.avatarlabel.text = ChatSession.receiveTitle()
            self.avatarlabel.isHidden = false
        }
    }
    
    func configureCell(message: ChatDBMessage) {
        scrollViewHeightConstraint.constant = 0.0
        dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)
        bubbleLabel.text = message.body
        guard let transactionsMessage = message.kind, message.canShowSuggestions else {
            self.updateConstraint()
            return
        }
        transactionResponse = Transactions.Map(transactionsMessage)
        guard let suggestions = transactionResponse?.suggestions, suggestions.count > 0  else {
            self.updateConstraint()
            return
        }
        for index in 0..<suggestions.count {
            if let welcomeStackView = ChatWorkflowManager.bundle.loadNibNamed("WelcomeStackView", owner: nil, options: nil)!.first as? WelcomeStackView {
                welcomeStackView.translatesAutoresizingMaskIntoConstraints = false
                welcomeStackView.selectButton.setTitle(suggestions[index].question, for: .normal)
                welcomeStackView.selectButton.tag = Int(message.messageId)
                welcomeStackView.widthAnchor.constraint(equalToConstant: welcomeStackView.selectButton.intrinsicContentSize.width + 20).isActive = true
                self.stackView.addArrangedSubview(welcomeStackView)
            }
        }
        scrollViewHeightConstraint.constant = 35.0
        self.updateConstraint()
    }
    
    private func updateConstraint() {
        self.stackView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    deinit {
        //transactionResponse = nil
    }

}
