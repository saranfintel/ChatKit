//
//  CardRecommendHelper.swift
//  Eva
//
//  Created by pooma on 4/17/18.
//  Copyright © 2018 Eva. All rights reserved.
//

import Foundation
import UIKit

class ChatCardRecommendHelper: NSObject {

    public static let CONNECTED_ACCOUNTS_CARD_NAME_LABEL_WIDTH = CGFloat(200.0)
    public static let CONNECTED_ACCOUNTS_CARD_LABEL_WIDTH = CGFloat(115.0)
    public static let CONNECTED_ACCOUNTS_CARD_VALUE_WIDTH = CGFloat(110.0)
    public static let CONNECTED_ACCOUNTS_LOGO_VALUE_WIDTH = CGFloat(140.0)
    public static let ACCOUNTS_CARD_NAME_HEIGHT = 18.0
    public static let ACCOUNTS_CARD_TYPE_HEIGHT = 13.0
    public static let ACCOUNTS_CARD_IMAGE_HEIGHT = CGFloat(20.0)
    public static let RECOMMEND_LABEL_HEIGHT = CGFloat(15.0)

    func configurePageControl(_ vc: ChatCardRecoCollectionViewCell?) {
        vc?.pageControl?.numberOfPages = vc?._arrCarouselItems?.count ?? 0
        vc?.pageControl?.currentPage = 0
        vc?.pageControl?.pageIndicatorTintColor = UIColor.colorFromHex(hexString: "#929292")
        vc?.pageControl?.currentPageIndicatorTintColor = ChatColor.mapGreenTheme()
    }

    func setupNavigationBar(_ vc: ChatCardRecoCollectionViewCell?) {
        vc?.backgroundColor = ChatColor.whiteTheme()
    }

    func setNotesProperties(_ vc: ChatCardRecoCollectionViewCell?) {
        vc?.lblDisplayNotes?.animationdelegate = vc;
//        vc?.lblDisplayNotes?.layoutTool.groupType = ZCLayoutGroupType(rawValue: 0)!;
        vc?.lblDisplayNotes?.animationDuration = 0.2;
        vc?.lblDisplayNotes?.animationDelay = 0.05;
        vc?.lblDisplayNotes?.textColor = ChatColor.blackTheme()
    }

    func loadScrollview(_ vc: ChatCardRecoCollectionViewCell?, cardRecommands: [CardRecommand]) {
        // Reset All view in scrollview to draw again when coming from other flow
        self.resetAllData(vc)
        vc?._arrCarouselItems?.removeAll()
        vc?._arrCarouselItems = ChatCardRecommendHelper.carouselItemsForCardRec(cardRecommands: cardRecommands)
        
        if let arrCarouselItems = vc?._arrCarouselItems {
            var index: Int = 0
            for evaCarouselItem in arrCarouselItems {
                let card = vc?.cards[index]
                let x =     CGFloat(CARDWIDTHSIZE * Double(index));
                let widthside =  CGFloat((index == 0) ? CARDWIDTHSIZE : (CARDWIDTHSIZE * 0.80))
                let heightside =  CGFloat((index == 0) ? CARDHEIGHTSIZE : (CARDHEIGHTSIZE * 0.85))
                evaCarouselItem.frame =    CGRect.init(x: 0, y: 0, width: widthside, height: heightside);
                evaCarouselItem.center =   CGPoint.init(x: (x + CGFloat(CARDWIDTHSIZE/2)), y: CGFloat(CARDHEIGHTSIZE/2));
                evaCarouselItem.backgroundColor = UIColor.init(hex: (card?.color_scheme ?? "" == "") ? DEFAULT_COLOR_SCHEME : card?.color_scheme ?? DEFAULT_COLOR_SCHEME)
                evaCarouselItem.layer.borderWidth = 0.0;
                
                vc?.scrollView?.addSubview(evaCarouselItem)
                ChatCardRecommendHelper.addRecommandationLabel(scrollView: vc?.scrollView ?? UIScrollView(), evaCarouselItem: evaCarouselItem, index: index)
                vc?.array = ChatCardRecommendHelper.addThumpsUpImage(scrollView: vc?.scrollView ?? UIScrollView(), evaCarouselItem: evaCarouselItem, index: index)
                ChatCardRecommendHelper.addCardName(vc?.scrollView ?? UIScrollView(), evaCarouselItem, index, card: card)
                ChatCardRecommendHelper.addCardType(vc?.scrollView ?? UIScrollView(), evaCarouselItem, index, card: card)
                ChatCardRecommendHelper.addCardEndingNumber(vc?.scrollView ?? UIScrollView(), evaCarouselItem, index, card: card)
                
                ChatCardRecommendHelper.addLogoImage(vc?.scrollView ?? UIScrollView(), evaCarouselItem, index, card: card)
                index += 1
            }
            vc?.setScrollViewProperties()
        }
    }

    /*
     Update position of Recommend label and Rating view position dynamically
     */
    func updateRatingPosition(_ scrollView: UIScrollView, _ index: Int, _ button: UIButton) {
        
        let _recommended = scrollView.viewWithTag(index + 1) as? EvaLeftInsetLabel
        let _ratingView = scrollView.viewWithTag(1900 + index)
        let _cardName = scrollView.viewWithTag(index + 100) as? EvaLeftInsetLabel
        let _cardType = scrollView.viewWithTag(200 + index) as? EvaLeftInsetLabel
        let _line = scrollView.viewWithTag(2000 + index) as? UIImageView
        let _logo = scrollView.viewWithTag(1800 + index) as? UIImageView
        let _logoLabel = scrollView.viewWithTag(1800 + index) as? UILabel
        let _cardEndNo = scrollView.viewWithTag(300 + index) as? EvaRightInsetLabel
        
        let btnOrigin = button.frame.origin
        let btnSize = button.frame.size
        
        if let recommended = _recommended {
            let origin = recommended.frame.origin
            let size = recommended.frame.size
            recommended.frame = CGRect.init(x: btnOrigin.x, y: origin.y , width: size.width , height: CGFloat(ChatCardRecommendHelper.ACCOUNTS_CARD_NAME_HEIGHT))
        }
        
        if let ratingView = _ratingView {
            let origin = ratingView.frame.origin
            let size = ratingView.frame.size
            let x = CGFloat(btnOrigin.x + btnSize.width - (size.width + 16))
            ratingView.frame = CGRect.init(x: x, y: origin.y , width: size.width , height: size.height)
        }
        
        if let cardName = _cardName {
            let origin = cardName.frame.origin
            let size = cardName.frame.size
            cardName.frame = CGRect.init(x: btnOrigin.x, y: origin.y , width: size.width , height: size.height)
        }
        
        if let cardType = _cardType {
            let origin = cardType.frame.origin
            let size = cardType.frame.size
            cardType.frame = CGRect.init(x: btnOrigin.x, y: origin.y , width: size.width , height: size.height)
        }
        
        if let line = _line {
            let origin = line.frame.origin
            let size = line.frame.size
            let x = btnOrigin.x + 16
            line.frame = CGRect.init(x: x, y: origin.y , width: (btnSize.width - 32.0) , height: size.height)
        }
        
        // Logo image is not there, check for institution_type label
        if let logo = _logo {
            let origin = logo.frame.origin
            let size = logo.frame.size
            logo.frame = CGRect.init(x: btnOrigin.x + 16.0, y: origin.y , width: size.width , height: size.height)
        } else if let logo = _logoLabel {
            let origin = logo.frame.origin
            let size = logo.frame.size
            logo.frame = CGRect.init(x: btnOrigin.x, y: origin.y , width: size.width , height: size.height)
        }
        
        if let cardEndNo = _cardEndNo {
            let origin = cardEndNo.frame.origin
            let size = cardEndNo.frame.size
            let x = CGFloat(btnOrigin.x + btnSize.width - size.width)
            cardEndNo.frame = CGRect.init(x: x, y: origin.y , width: size.width , height: size.height)
        }
    }

}

extension ChatCardRecommendHelper {
    
    /*
     add Card item in array
     */
    public static func carouselItemsForCardRec(cardRecommands: [CardRecommand]?) -> Array<EvaCarouselItem> {
        
        var array = Array<EvaCarouselItem>()
        let count = cardRecommands?.count ?? 0
        for _ in 0..<count {
            let item = self.createCarouselItem()
            array.append(item)
        }
        return array
    }
    
    public static func createCarouselItem() -> EvaCarouselItem {
        let item1:EvaCarouselItem = EvaCarouselItem(title: "Basketball", image: UIImage(named: "btn-basketball.png"), target:nil, action:nil)
        return item1
    }

    /*
     Add Recommend label in scrollview
     */
    public static func addRecommandationLabel(scrollView: UIScrollView, evaCarouselItem: EvaCarouselItem, index: Int) {
        let label = EvaLeftInsetLabel()
        label.frame = CGRect.init(x: evaCarouselItem.frame.origin.x, y: CGFloat(148.0), width: evaCarouselItem.frame.size.width, height: CGFloat(RECOMMEND_LABEL_HEIGHT))
        label.textAlignment = .left
        label.font = ChatUtils.getFont(of: "Helvetica Neue", of: 12.0)
        label.text = "Recommended"
        label.textColor = UIColor.white
        label.tag = index + 1
        scrollView.addSubview(label)
    }
    
    /*
     Add Ratings view in scrollview
     */
    public static func addThumpsUpImage(scrollView: UIScrollView, evaCarouselItem: EvaCarouselItem, index: Int) -> Array<WCLShineButton> {
        
        let size = 15
        let rightPadding = 16
        let space = 5 // space between star
        let totalwidth = Int(size + space) // single star size + space = total width
        let starCount = 5
        let width = (size * starCount) + (space * (starCount - 1)) //5 stars, 4 in between space = 120 width
        var y = Int(148.0)
        var x = Int(evaCarouselItem.frame.size.width - CGFloat(rightPadding))
        
        let ratingView = UIView(frame: CGRect.init(x: x, y: y, width: width, height: size))
        ratingView.tag = 1900 + index
        scrollView.addSubview(ratingView)
        
        x = 0
        y = 0
        var param = WCLShineParams()
        param.enableFlashing = true
        let bt1 = self.addStar(x: x, y: y, width: size, height: size, params: param)
        ratingView.addSubview(bt1)
        x += totalwidth
        let bt2 = self.addStar(x: x, y: y, width: size, height: size, params: param)
        ratingView.addSubview(bt2)
        x += totalwidth
        let bt3 = self.addStar(x: x, y: y, width: size, height: size, params: param)
        ratingView.addSubview(bt3)
        x += totalwidth
        let bt4 = self.addStar(x: x, y: y, width: size, height: size, params: param)
        ratingView.addSubview(bt4)
        x += totalwidth
        let bt5 = self.addStar(x: x, y: y, width: size, height: size, params: param)
        ratingView.addSubview(bt5)
        
        return [bt1,bt2, bt3, bt4, bt5];
    }

    /*
     Add star in Rating view
     */
    public static func addStar(x: Int, y: Int, width: Int, height: Int, params: WCLShineParams) -> WCLShineButton {
        var param2 = WCLShineParams()
        param2.bigShineColor = UIColor(rgb: (255, 204, 0))
        param2.smallShineColor = UIColor(rgb: (216,152,148))
        param2.shineCount = 15
        param2.smallShineOffsetAngle = -5
        let bt2 = WCLShineButton(frame: .init(x: x, y: y, width: width, height: height), params: param2)
        bt2.fillColor = UIColor(rgb: (255, 204, 0))
        bt2.color = UIColor.white
        bt2.image = .like
        return bt2
    }
    
    /*
     Add Card Name in scrollview
     */
    public static func addCardName(_ scrollView: UIScrollView, _ evaCarouselItem: EvaCarouselItem, _ index: Int, _ account: Account? = nil, card: CardRecommand? = nil) {
        let label = EvaLeftInsetLabel()
        label.frame = CGRect.init(x: evaCarouselItem.frame.origin.x, y: CGFloat(51.0), width: CGFloat(CONNECTED_ACCOUNTS_CARD_NAME_LABEL_WIDTH), height: CGFloat(ACCOUNTS_CARD_NAME_HEIGHT))
        label.textAlignment = .left
        label.font = ChatUtils.getFont(of: "Helvetica Neue", of: 15.0)
        if (account == nil) {
            label.attributedText = ChatUtils.formatPoint8Text(text: card?.name ?? "")
        } else {
            label.attributedText = ChatUtils.formatPoint8Text(text: account?.name ?? "")
        }
        label.textColor = ChatColor.whiteTheme()
        label.tag = index + 100
        scrollView.addSubview(label)
    }
    
    /*
     Add Card Type in scrollview
     */
    public static func addCardType(_ scrollView: UIScrollView, _ evaCarouselItem: EvaCarouselItem, _ index: Int, _ account: Account? = nil, card: CardRecommand? = nil) {
        let label = EvaLeftInsetLabel()
        let width = CGFloat(150.0)
        label.frame = CGRect.init(x: evaCarouselItem.frame.origin.x, y: CGFloat(77.0), width: width, height: CGFloat(17.0))
        label.textAlignment = .left
        label.font = ChatUtils.getFont(of: "Helvetica Neue", of: 13.0)
        if (account == nil) {
            label.attributedText = ChatUtils.formatPoint8Text(text: card?.subtype ?? "")
        } else {
            label.attributedText = ChatUtils.formatPoint8Text(text: account?.subtype ?? "")
        }
        label.textColor = UIColor.colorFromHex(hexString: "#FFFFFF")
        label.tag = index + 200
        scrollView.addSubview(label)
    }

    /*
     Add Card Ending No in scrollview
     */
    public static func addCardEndingNumber(_ scrollView: UIScrollView, _ evaCarouselItem: EvaCarouselItem, _ index: Int, _ account: Account? = nil, card: CardRecommand? = nil) {
        
        let width = CGFloat(120.0)
        let y = CGFloat(54.0)
        let x = CGFloat(evaCarouselItem.frame.size.width - CGFloat(width))
        
        let label = EvaRightInsetLabel()
        label.frame = CGRect.init(x: x, y: y, width: width, height: CGFloat(ACCOUNTS_CARD_TYPE_HEIGHT))
        label.textAlignment = .right
        label.font = ChatUtils.getFont(of: "Helvetica Neue", of: 13.0)
        if (account == nil) {
            let formattedEndingNo = card?.ending_number ?? ""
            label.attributedText = ChatUtils.formatPoint8Text(text: (formattedEndingNo == "") ? "" : "**** "+formattedEndingNo)
        } else {
            let formattedEndingNo = account?.ending_number ?? ""
            label.attributedText = ChatUtils.formatPoint8Text(text: (formattedEndingNo == "") ? "" : "**** "+formattedEndingNo)
        }
        label.tag = index + 300
        label.textAlignment = .right
        label.textColor = UIColor.colorFromHex(hexString: "#FFFFFF")
        scrollView.addSubview(label)
    }
    
    public static func addLogoImage(_ scrollView: UIScrollView, _ evaCarouselItem: EvaCarouselItem, _ index: Int, _ account: Account? = nil, card: CardRecommand? = nil) {
        let imageView = UIImageView()
        imageView.frame = CGRect.init(x: 16, y: CGFloat(25.0), width: ChatCardRecommendHelper.CONNECTED_ACCOUNTS_LOGO_VALUE_WIDTH, height: ChatCardRecommendHelper.ACCOUNTS_CARD_IMAGE_HEIGHT)
        let imageName : String? = ((account == nil) ? card?.institution_id : account?.institution_id)
        imageView.image = UIImage.init(named: "default", in: ChatWorkflowManager.bundle, compatibleWith: nil)//UIImage(named: "default")
        if var name = imageName {
            name = name + "_darkbg"
            imageView.image = UIImage.init(named: name.lowercased(), in: ChatWorkflowManager.bundle, compatibleWith: nil)//UIImage(named:name.lowercased())
        }
        
        if imageView.image == nil {
            let label = EvaLeftInsetLabel()
            label.frame = CGRect.init(x: 0, y: CGFloat(25.0), width: ChatCardRecommendHelper.CONNECTED_ACCOUNTS_CARD_LABEL_WIDTH, height: ChatCardRecommendHelper.ACCOUNTS_CARD_IMAGE_HEIGHT)
            label.textAlignment = .left
            label.font = ChatUtils.getFont(of: "Helvetica Neue", of: 15.0)
            if (account == nil) {
                label.attributedText = ChatUtils.formatPoint8Text(text: card?.institution_name ?? "")
            } else {
                label.attributedText = ChatUtils.formatPoint8Text(text: account?.institution_name ?? "")
            }
            label.textColor = UIColor.colorFromHex(hexString: "#FFFFFF")
            label.tag = index + 1800
            scrollView.addSubview(label)
        } else {
            imageView.tag = index + 1800
            imageView.contentMode = .left
            scrollView.addSubview(imageView)
        }
        
        if account == nil {
            self.addLineImage(scrollView, evaCarouselItem, index, card: card)
        }
    }
    
    
    public static func addLineImage(_ scrollView: UIScrollView, _ evaCarouselItem: EvaCarouselItem, _ index: Int, _ account: Account? = nil, card: CardRecommand? = nil) {
        let imageView = UIImageView(frame:CGRect.init(x: 16, y: 130, width: 270, height: 0.5));
        imageView.tag = index + 2000
        imageView.backgroundColor = UIColor.colorFromHex(hexString: "#F5F7FA")
        scrollView.addSubview(imageView)
    }
    
}
extension ChatCardRecommendHelper {
    
    func animateWhenCardChanges(_ vc: ChatCardRecoCollectionViewCell?, count: Int, page: Int) {
        for index in 0..<count {
            if let scrollView = vc?.scrollView, let ratingView = scrollView.viewWithTag(1900 + index) {
                if page == index {
                    if (page >= 0 && page < vc?._arrCarouselItems?.count ?? 0) {
                        self.reset(ratingView: ratingView)
                        vc?.animate(ratingView: ratingView)
                    }
                } else {
                    self.reset(ratingView: ratingView)
                }
            }
        }
    }
    
    /*
     Invalidate timer
     */
    func invalidateTimer(_ vc: ChatCardRecoCollectionViewCell?) {
        vc?.counter = 0
        vc?.timer.invalidate()
    }
    
    /*
     Reset Thumbs up image after scrolling to Left or Right side
     */
    func reset(ratingView : UIView) {
        for button in ratingView.subviews {
            if let shineButton = button as? WCLShineButton {
                shineButton.resetanimating()
            }
        }
    }
    
    /*
     Reset All view in scrollview to draw again when coming from other flow
     */
    func resetAllData(_ vc: ChatCardRecoCollectionViewCell?) {
        vc?.lastpage = -1
        if let subviews = vc?.scrollView?.subviews {
            for view in subviews  {
                view.removeFromSuperview()
            }
        }
    }
    
    
    func resetScreenData(_ vc: ChatCardRecoCollectionViewCell?) {
        self.resetAllData(vc)
        vc?._arrCarouselItems?.removeAll()
        vc?.hideNotes()
    }
}
