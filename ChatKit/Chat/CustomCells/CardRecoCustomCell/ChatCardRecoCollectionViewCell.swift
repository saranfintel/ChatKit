//
//  ChatCardRecoCollectionViewCell.swift
//  ChatApp
//
//  Created by pooma on 12/24/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import MessageKit

class ChatCardRecoCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate, AnimationDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var vCarousel: UIView?
    @IBOutlet weak var lblDisplayNotes: ZCAnimatedLabel?
    @IBOutlet weak var textViewDisplayNotes: UITextView?
    @IBOutlet weak var pageControl : UIPageControl?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var avatarlabel: ChatLabel!

    var _arrCarouselItems: Array<ChatCarouselItem>?
    var array = [WCLShineButton]()
    var counter = 0
    var rankCounter = 0
    var timer = Timer()
    var lastpage = -1
    
    var cards: [CardRecommand] = []
    var cardRecommendHelper: ChatCardRecommendHelper? = ChatCardRecommendHelper()
    
    // variable to save the last position visited, default to zero
    private var lastContentOffset: CGFloat = 0
    private var isLeftSwipe: Bool = true
    private var hideExecute: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func setupView() {
        if let icon = ChatSession.receiveIcon() {
            self.avatarIcon.image = icon
            self.avatarIcon.isHidden = false
        } else {
            self.avatarlabel.text = ChatSession.receiveTitle()
            self.avatarlabel.isHidden = false
        }
        cardRecommendHelper?.setupNavigationBar(self)
        cardRecommendHelper?.setNotesProperties(self)
    }

    func configurationCell(message: ChatDBMessage) {
        guard let transactionsMessage = message.kind, let transactionResponse = Transactions.Map(transactionsMessage) else {
            return
        }
        cards = transactionResponse.cardRecommands
        dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)
        
        self.updateUI()
    }

    
    func updateUI() {
        cardRecommendHelper?.loadScrollview(self, cardRecommands: cards)
        cardRecommendHelper?.configurePageControl(self)
    }
    
    
    func setScrollViewProperties() {
        
        scrollView?.frame = CGRect.init(x: 0, y: 0, width: CARDWIDTHSIZE, height: CARDHEIGHTSIZE)
        scrollView?.contentSize = CGSize.init(width: CARDWIDTHSIZE*Double(_arrCarouselItems?.count ?? 0), height: CARDHEIGHTSIZE )
        // Don't delete the next line.
        scrollView?.contentOffset = CGPoint.init(x: 20, y: 0)
        scrollView?.contentOffset = CGPoint.init(x: 0, y: 0)
        isLeftSwipe = true
        scrollView?.center = CGPoint.init(x: (vCarousel?.frame.size.width ?? 0) / 2 , y: (vCarousel?.frame.size.height ?? 0) / 2)
        scrollView?.delegate = self
        scrollView?.setNeedsDisplay()
        let when = DispatchTime.now() + 0.05 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.scrollViewDidEndDecelerating(self.scrollView ?? UIScrollView())
        }
    }
    
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let count: Int = _arrCarouselItems?.count ?? 0
        var offset = scrollView.contentOffset
        self.updateScrollPosition(scrollView: scrollView)
        self.hideNotes()
        for index in 0..<count {
            let button: UIButton = _arrCarouselItems![index]
            cardRecommendHelper?.updateRatingPosition(scrollView, index, button)
            if offset.x > CGFloat(CARDWIDTHSIZE*Double(index+1)) || offset.x < CGFloat(CARDWIDTHSIZE*Double(index-1)) {
                continue
            }
            // adjust size of buttons to the LEFT of UIScrollView
            if offset.x > CGFloat(Double(index)*CARDWIDTHSIZE) {
                var frame: CGRect = button.frame
                frame.size.width = CGFloat(CARDWIDTHSIZE)-((offset.x-CGFloat(Double(index)*CARDWIDTHSIZE))*0.20)
                frame.size.height = CGFloat(CARDHEIGHTSIZE)-((offset.x-CGFloat(Double(index)*CARDWIDTHSIZE))*0.08)
                button.frame = frame
                button.center = CGPoint.init(x: ((CARDWIDTHSIZE*Double(index))+(CARDWIDTHSIZE/2)), y: (CARDHEIGHTSIZE/2))
                continue
            }
            // adjust size of buttons to the RIGHT of UIScrollView
            if offset.x < CGFloat(Double(index)*CARDWIDTHSIZE) {
                var frame: CGRect = button.frame
                frame.size.width = CGFloat(CARDWIDTHSIZE)+((offset.x-CGFloat(Double(index)*CARDWIDTHSIZE))*0.20)
                frame.size.height = CGFloat(CARDHEIGHTSIZE)+((offset.x-CGFloat(Double(index)*CARDWIDTHSIZE))*0.08)
                button.frame = frame
                button.center = CGPoint.init(x: ((CARDWIDTHSIZE*Double(index))+(CARDWIDTHSIZE/2)), y: (CARDHEIGHTSIZE/2))
            }
        }
        
        if offset.y != 0 {
            offset.y = 0
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = CGFloat(scrollView.frame.size.width )
        let contentOffsetX = scrollView.contentOffset.x
        let page: Int = Int(floor((contentOffsetX - pageWidth / 2) / pageWidth)) + 1;
        let count: Int = _arrCarouselItems?.count ?? 0
        // User does scrolling on the same page before moving to next page - Don't animate
        if lastpage == page {
            self.showNotes(page: page)
            return
        }
        // Loading different card? then animate & update the page index
        lastpage = page
        self.pageControl?.currentPage = page
        cardRecommendHelper?.animateWhenCardChanges(self, count: count, page: page)
    }
    
    func updateScrollPosition(scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.x) { isLeftSwipe = false }
        else if (self.lastContentOffset < scrollView.contentOffset.x) { isLeftSwipe = true }
        self.lastContentOffset = scrollView.contentOffset.x
    }
    
    func showNotes(page: Int) {
       if self.cards.count == 0 { return }
        var index = 0
        if page > 0 {
            index = page
        }
        let card = getCardAtIndex(index: index)
        if card.notes.emojiUnescapedString == "" {
            lblDisplayNotes?.isHidden = true
            textViewDisplayNotes?.isHidden = true
            return
        }
        if self.frame.size.width > 320 {
            textViewDisplayNotes?.isHidden = true
            lblDisplayNotes?.startAppearAnimation()
            let notes = card.notes.emojiUnescapedString
            lblDisplayNotes?.attributedString = ChatUtils.stringMediumFontFromHtml(string: notes.addBRtag())
            _ = Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(showAfterDelay), userInfo: nil, repeats: false)
        } else {
            let notes = card.notes.emojiUnescapedString
            textViewDisplayNotes?.isHidden = false
            lblDisplayNotes?.isHidden = true
            textViewDisplayNotes?.textContainerInset = UIEdgeInsets.init(top: -5.0, left: 0, bottom: 0, right: 0)
            textViewDisplayNotes?.attributedText = ChatUtils.stringMediumFontFromHtml(string: notes.addBRtag())
        }
    }
    
    func getCardAtIndex(index: Int) -> CardRecommand {
        if index < self.cards.count {
            return self.cards[index]
        }
        return CardRecommand.empty()
    }
    
    @objc func showAfterDelay() {
        lblDisplayNotes?.isHidden = false
    }
    
    func hideNotes() {
        textViewDisplayNotes?.isHidden = true
        lblDisplayNotes?.isHidden = true
        lblDisplayNotes?.stopAnimation()
    }
    
    func didFinishLoadingLabel(_ label: UIView?) {
    }
    
    /*
     Trigger timer to animate the Thumbs up image
     */
    func animate(ratingView : UIView) {
        // Reset array & invalidate timer before animating
        array.removeAll()
        cardRecommendHelper?.invalidateTimer(self)
        if self.cards.count > lastpage {
            let card = self.cards[lastpage]
            rankCounter = card.total_thumbs_up
        }
        
        // Get each subviews from rating view and animate
        for button in ratingView.subviews {
            if let shineButton = button as? WCLShineButton {
                array.append(shineButton)
            }
        }
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    /*
     Start the Thumbs up animation
     */
    @objc func timerAction() {
        if counter < array.count && counter < rankCounter {
            let WCLShineButton = array[counter]
            WCLShineButton.startanimating()
            counter += 1
        }
        else {
            self.showNotes(page: lastpage)
            cardRecommendHelper?.invalidateTimer(self)
        }
    }
    
    deinit {
        //transactionResponse = nil
    }
}

