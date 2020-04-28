//
//  ChatViewController+FloatingView.swift
//  ChatKit
//
//  Created by saran on 28/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import InputBarAccessoryView

extension ChatViewController {
    func loadmoreButtonPressed(_ cell: UICollectionViewCell) {
        print("loadmoreButtonPressed")
        guard let indexPath = self.messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = self.fetchedResultsController.object(at: indexPath)
        self.hitDB(body: message.body ?? "")
    }
    
    @objc func thingMayAskTapped(_ recognizer: UIGestureRecognizer?) {
        print("thingMayAskTapped")
        messageInputBar.topStackView.removeArrangedSubview(floatingQuestionView)
        NSLayoutConstraint.deactivate(messageInputBar.topStackView.constraints)
        messageInputBar.topStackView.heightAnchor.constraint(equalToConstant: floatingQuestionViewFlag ? 50.0 : 325.0).isActive = true
        floatingQuestionView.contentView?.isHidden = floatingQuestionViewFlag
        messageInputBar.setStackViewItems([floatingQuestionView], forStack: .top, animated: false)
        let thingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.thingMayAskTapped(_:)))
        thingsTapGesture.numberOfTapsRequired = 1
        floatingQuestionView.headerLabel?.addGestureRecognizer(thingsTapGesture)
        messageInputBar.layoutStackViews()
        floatingQuestionViewFlag = !floatingQuestionViewFlag
    }
}

class FloatingView: UIView, InputItem {
    
    var inputBarAccessoryView: InputBarAccessoryView?
    var parentStackViewPosition: InputStackView.Position?
    
    func textViewDidChangeAction(with textView: InputTextView) { }
    func keyboardSwipeGestureAction(with gesture: UISwipeGestureRecognizer) { }
    func keyboardEditingEndsAction() { }
    func keyboardEditingBeginsAction() { }
    
    let thingsLabel: UILabel = UILabel()

    let flyingView: UIView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCustomView()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomView() {
        self.backgroundColor = ChatColor.appTheme()
        thingsLabel.frame = CGRect(x: 0, y: 15, width: self.frame.size.width, height: 21)
        thingsLabel.backgroundColor=UIColor.green
        thingsLabel.textAlignment = NSTextAlignment.center
        thingsLabel.isUserInteractionEnabled = true
        thingsLabel.text = "Things you may ask"
        self.addSubview(thingsLabel)
        
        flyingView.frame = CGRect(x: 0, y: 50, width: self.frame.size.width, height: 200)
        flyingView.backgroundColor = ChatColor.appTheme()
        flyingView.isHidden = true
        self.addSubview(flyingView)
        flyingView.clipsToBounds = true

        self.heightConstaint?.constant = 50
    }
}


extension UIView {
    var heightConstaint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
}
