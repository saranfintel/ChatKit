//
//  ChatCustomMessagesFlowLayout.swift
//  ChatApp
//
//  Created by Sarankumar on 17/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation
import MessageKit

open class ChatCustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    
    open lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    open var message: MessageType?
    
    open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom? = message?.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath)
    }
    
    open override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var superCalculators = super.messageSizeCalculators()
        // Append any of your custom `MessageSizeCalculator` if you wish for the convenience
        // functions to work such as `setMessageIncoming...` or `setMessageOutgoing...`
        superCalculators.append(customMessageSizeCalculator)
        return superCalculators
    }
}

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    
    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        self.layout = layout
    }
    
    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let layout = layout else { return .zero }
        
        let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right
        let width = collectionViewWidth - inset
        return CGSize(width: width, height: getCellHeight(width: width))
    }
    
    private func getCellHeight(width: CGFloat) -> CGFloat {
        let height = CGFloat(0.0)
        guard let _layout = layout as? ChatCustomMessagesFlowLayout, let layoutMessage = _layout.message else {
            return height
        }
        if case .custom(let data) = layoutMessage.kind {
            guard let messageDB = data as? ChatDBMessage else {
                return height
            }
            return CGFloat(CFloat(messageDB.chatHeight))
        }
        return height
    }
}


