//
//  ChatViewController+MessageCellDelegate.swift
//  ChatApp
//
//  Created by saran on 07/05/19.
//  Copyright © 2019 Saran. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AVKit
import AVFoundation
import SafariServices

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didSelectURL(_ url: URL) {
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
        if ChatUtils.isEligibleToPlayVideo(cell: cell) {
            if (player != nil && (player?.rate != 0) && (player?.error == nil)) {
                player?.pause()
                playerLayer.removeFromSuperlayer()
                player = nil
            } else {
                let videoURL: URL = Bundle.main.url(forResource: "onboard1", withExtension: "mp4")!
                player = AVPlayer(url: videoURL)
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = CGRect(x:-45, y: 0, width: cell.frame.width + 40, height: cell.frame.height)
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                cell.layer.addSublayer(playerLayer)
                player?.play()
                
                NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.stopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
            }
        }
    }
    @objc func stopVideo() {
        playerLayer.removeFromSuperlayer()
        player = nil
    }
    
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}
