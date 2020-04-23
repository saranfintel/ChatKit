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
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var bubbleLabel: UILabel!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
//    var transactionResponse: Transactions? = nil
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var imgView: UIImageView?


    override open func awakeFromNib() {
        super.awakeFromNib()
        bubbleView.layer.borderWidth = 1.0
        bubbleView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        bubbleView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        bubbleView.layer.cornerRadius = 15.0
        bubbleView.layer.masksToBounds = true
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
        self.imgView?.image = UIImage(named: senderImage)
    }
    
    func configureCell(message: ChatDBMessage) {
            /*dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)
            bubbleLabel.text = message.body
            scrollViewHeightConstraint.constant = 0.0
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
                if let welcomeStackView = Bundle.main.loadNibNamed("WelcomeStackView", owner: nil, options: nil)!.first as? WelcomeStackView {
                    welcomeStackView.translatesAutoresizingMaskIntoConstraints = false
                    welcomeStackView.selectButton.setTitle(suggestions[index].question, for: .normal)
                    welcomeStackView.selectButton.tag = Int(message.messageId)
                    welcomeStackView.widthAnchor.constraint(equalToConstant: welcomeStackView.selectButton.intrinsicContentSize.width + 20).isActive = true
                    self.stackView.addArrangedSubview(welcomeStackView)
                }
            }
            scrollViewHeightConstraint.constant = 35.0
            self.updateConstraint()*/
    }
    
    private func updateConstraint() {
        self.stackView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    deinit {
        //transactionResponse = nil
    }

}
