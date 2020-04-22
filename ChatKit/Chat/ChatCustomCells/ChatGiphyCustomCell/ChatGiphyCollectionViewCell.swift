//
//  ChatGiphyCollectionViewCell.swift
//  ChatApp
//
//  Created by saran on 29/04/19.
//  Copyright © 2019 Saran. All rights reserved.
//

import UIKit
import Kingfisher

open class ChatGiphyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var giphyButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!

    override open func awakeFromNib() {
        super.awakeFromNib()
        bubbleView.layer.borderWidth = 1.0
        bubbleView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        bubbleView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        bubbleView.layer.cornerRadius = 15.0
        bubbleView.layer.masksToBounds = true
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
        self.imageView.kf.setImage(with: URL(string:"https://s3-us-west-2.amazonaws.com/fintellabs-apps/Images/Hello.gif"), placeholder: nil, options: nil, progressBlock: nil, completionHandler: {
            image, error, cacheType, imageURL in
            if let image = image {
                self.imageView.animationImages = image.images
                self.imageView.animationDuration = image.duration
                self.imageView.animationRepeatCount = 4
                self.imageView.image = image.images?.last
            }
        })
    }

    @IBAction func giphyButtonTapped(_ sender: Any) {
        if let button = sender as? UIButton {
            if button.isSelected {
                giphyButton.isSelected = false
                giphyButton.setImage(UIImage(named: "GIF"), for: .normal)
                self.imageView.stopAnimating()
            } else {
                giphyButton.isSelected = true
                giphyButton.setImage(nil, for: .normal)
                self.imageView.startAnimating()
            }
        }
    }
}
