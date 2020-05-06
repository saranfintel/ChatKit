//
//  SiriContentView.swift
//  Eva
//
//  Created by Poomalai on 4/1/17.
//  Copyright © 2017 Eva. All rights reserved.
//

import UIKit
import QuartzCore
import InputBarAccessoryView

@objc
protocol categoryNameDelegate {
    @objc func categoryNameChanged(index: Int)
}

class SiriContentView: UIView, InputItem {
    
    @IBOutlet weak var headerLabel: UILabel?
    @IBOutlet weak var carouselLineView: UIView!
    @IBOutlet weak var contentView: UIView?

    @IBOutlet weak var firstInfoLabel: UILabel?
    @IBOutlet weak var secondInfoLabel: UILabel?
    @IBOutlet weak var thirdInfoLabel: UILabel?
    @IBOutlet weak var fourthInfoLabel: UILabel?
    
    @IBOutlet weak var firstLblTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondLblTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdLblTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourthLblTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var categoryNameCarousel: ChatSwiftCarousel!
    var items: [String]?
    var itemsViews: [UILabel]?

    //Delegate
    weak var delegate: categoryNameDelegate?

    //Animation related
    var infoBasearray = [[UILabel]]()
    var infoLabelarray1 = [UILabel]()
    var infoLabelarray2 = [UILabel]()
    var infoLabelarray3 = [UILabel]()
    
    var baseCounter = 0
    var showCounter = 0
    var hideCounter = 0

    var infoLabelPositionarray = [240, 307, 353, 420, 466, 512]
    var showTimer = Timer()
    var hideTimer = Timer()
    var baseTimer = Timer()
    var task: DispatchWorkItem? = nil
    var isResetExecuted = false
    var autoSelectExecuted = false

    var inputBarAccessoryView: InputBarAccessoryView?
    var parentStackViewPosition: InputStackView.Position?

    class func instanceFromNib() -> SiriContentView {
        guard let view = ChatWorkflowManager.bundle.loadNibNamed("SiriContentView", owner: self, options: nil)?.first as? SiriContentView else {
            return SiriContentView()
        }
        return view
    }

    init?(frame: CGRect, message: String) {
        super.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setOldProperties() {
//        self.roundCorners([.topLeft, .topRight], radius: 15.0)
        self.setupScroll()

        isResetExecuted = false
        baseCounter = 0
        hideCounter = 0

        self.headerLabel?.isUserInteractionEnabled = true
        self.firstInfoLabel?.isUserInteractionEnabled = true
        self.secondInfoLabel?.isUserInteractionEnabled = true
        self.thirdInfoLabel?.isUserInteractionEnabled = true
        self.fourthInfoLabel?.isUserInteractionEnabled = true
        
        infoBasearray.removeAll()
        
        self.firstInfoLabel?.text = ""
                
        self.firstInfoLabel?.attributedText = self.formatPoint18Text(text: "How much did I spend on travel last month?")
        self.secondInfoLabel?.attributedText = self.formatPoint18Text(text: "What’s my net worth?")
        self.thirdInfoLabel?.attributedText = self.formatPoint18Text(text: "Show me my shopping transactions for last three months")
        self.fourthInfoLabel?.attributedText = self.formatPoint18Text(text: "Show me my spend by category")
        headerLabel?.backgroundColor = ChatColor.appTheme()
        self.firstInfoLabel?.textColor = ChatColor.appTheme()
        self.secondInfoLabel?.textColor = ChatColor.appTheme()
        self.thirdInfoLabel?.textColor = ChatColor.appTheme()
        self.fourthInfoLabel?.textColor = ChatColor.appTheme()
        self.carouselLineView.backgroundColor = ChatColor.appTheme()
        infoLabelarray1 = [self.firstInfoLabel ?? UILabel(), self.secondInfoLabel ?? UILabel(), self.thirdInfoLabel ?? UILabel(), self.fourthInfoLabel ?? UILabel()];
        infoLabelarray2 = [self.firstInfoLabel ?? UILabel(), self.secondInfoLabel ?? UILabel(), self.thirdInfoLabel ?? UILabel(), self.fourthInfoLabel ?? UILabel()];
        infoLabelarray3 = [self.firstInfoLabel ?? UILabel(), self.secondInfoLabel ?? UILabel(), self.thirdInfoLabel ?? UILabel(), self.fourthInfoLabel ?? UILabel()];

        infoBasearray = [infoLabelarray1, infoLabelarray2, infoLabelarray3]

        self.animateBoard()
        self.autoSelectExecuted = true
        baseTimer = Timer.scheduledTimer(timeInterval: 13.8, target: self, selector: #selector(animateBoard), userInfo: nil, repeats: true)
        
    }
    
    func setLayoutProperties() {
        infoBasearray.removeAll()
        self.invalidateAllTimer()

        if ChatWorkflowManager.sharedManager.currentQuestionsList.count == 0 {
            self.setOldProperties()
            return
        }
        isResetExecuted = false
        baseCounter = 0
        hideCounter = 0
        
        self.headerLabel?.isUserInteractionEnabled = true
        self.firstInfoLabel?.isUserInteractionEnabled = true
        self.secondInfoLabel?.isUserInteractionEnabled = true
        self.thirdInfoLabel?.isUserInteractionEnabled = true
        self.fourthInfoLabel?.isUserInteractionEnabled = true

        self.firstInfoLabel?.isHidden = false
        self.secondInfoLabel?.isHidden = false
        self.thirdInfoLabel?.isHidden = false
        self.fourthInfoLabel?.isHidden = false

        infoBasearray.removeAll()
        
        self.firstInfoLabel?.text = ""
                
        let setCount = self.getLoopCount()
        
        for index in 0..<setCount {
            
            let originalIndex = 0
            var question = self.getQuestion(of: originalIndex, index: index)
            if question == "" {
                self.firstInfoLabel?.isHidden = true
            } else {
                self.firstInfoLabel?.attributedText = self.formatPoint18Text(text: question)
            }
            
            question = self.getQuestion(of: originalIndex+1, index: index)
            if question == "" {
                self.secondInfoLabel?.isHidden = true
            } else {
                self.secondInfoLabel?.attributedText = self.formatPoint18Text(text: question)
            }

            question = self.getQuestion(of: originalIndex+2, index: index)
            if question == "" {
                self.thirdInfoLabel?.isHidden = true
            } else {
                self.thirdInfoLabel?.attributedText = self.formatPoint18Text(text: question)
            }

            question = self.getQuestion(of: originalIndex+3, index: index)
            if question == "" {
                self.fourthInfoLabel?.isHidden = true
            } else {
                self.fourthInfoLabel?.attributedText = self.formatPoint18Text(text: question)
            }
            
            infoLabelarray1.removeAll()
            
            infoLabelarray1 = [self.firstInfoLabel ?? UILabel(), self.secondInfoLabel ?? UILabel(), self.thirdInfoLabel ?? UILabel(), self.fourthInfoLabel ?? UILabel()];
            
            infoBasearray.append(infoLabelarray1)
        }
        
        self.animateBoard()
        self.autoSelectExecuted = true
        baseTimer = Timer.scheduledTimer(timeInterval: 14.5, target: self, selector: #selector(animateBoard), userInfo: nil, repeats: true)
    }

    func getLoopCount() -> Int{
        let questionsList = ChatWorkflowManager.sharedManager.currentQuestionsList
        let group_ids = questionsList.map { $0.group_id}
        let uniquegroup_ids = Set(group_ids)
        let uniquegroupids = Array(uniquegroup_ids)
        let count = uniquegroupids.count
        return count
    }
    
     func getCategoryNames() -> Array<String>? {
        let questionsList = ChatWorkflowManager.sharedManager.currentQuestionsList
        let sortedQuestionsList = questionsList.sorted{ $0.group_id < $1.group_id}
        let categoryNames = sortedQuestionsList.map { $0.category }
        let uniqueCategory_Names = NSOrderedSet(array:categoryNames)
        if let uniqueCategoryNames:Array<String> = Array(uniqueCategory_Names) as? Array<String>, uniqueCategoryNames.count > 0 {
            return uniqueCategoryNames
        }
        return ["Financial Health", "Spend Insights", "Credit Score"]
    }
    
    
    func getCategoryName(index: Int) -> String {
        let questionsList = ChatWorkflowManager.sharedManager.currentQuestionsList
        let group_ids = questionsList.map { $0.group_id}
        let uniquegroup_ids = Set(group_ids)
        let uniquegroupids = Array(uniquegroup_ids)
        if uniquegroupids.count > index {
            let groupId = uniquegroupids[index]
            let groupIdQuestions = questionsList.filter( { return $0.group_id == groupId } )
            //print("groupId === \(groupId)")
            if groupIdQuestions.count > 0 {
                let question = groupIdQuestions[0]
                return question.category
            }
        }
        return ""
    }

    
    func getQuestion(of originalIndex: Int, index: Int) -> String {
        let questionsList = ChatWorkflowManager.sharedManager.currentQuestionsList
        let group_ids = questionsList.map { $0.group_id}
        let uniquegroup_ids = Set(group_ids)
        let uniquegroupids = Array(uniquegroup_ids)
        if uniquegroupids.count > index {
            //let groupId = uniquegroupids[index]
            let groupIdQuestions = questionsList.filter( { return $0.group_id == index } )
            //print("groupId === \(index)")
            if groupIdQuestions.count > originalIndex {
                let question = groupIdQuestions[originalIndex]
                return question.question_text
            }
        }
        return ""
    }

    /*
     Trigger timer to animate the Thumbs up image
     */
    @objc func animateBoard() {
        self.invalidateTimer()
        if baseCounter >= infoBasearray.count || baseCounter < 0 {
            baseCounter = 0
        }
        //print("baseCounter \(baseCounter)")
        let array = infoBasearray[baseCounter]

        var count = 0
        for label in array {
            label.isHidden = false
            if ChatWorkflowManager.sharedManager.currentQuestionsList.count > 0 {
                let originalIndex = count
                let question = self.getQuestion(of: originalIndex, index: baseCounter)
                if question == "" {
                    label.isHidden = true
                } else {
                    label.attributedText = self.formatPoint18Text(text: question)
                }
            }
            label.alpha = 0.0
            count += 1
        }
       // self.CategoryInfoLabel?.text = self.getCategoryName(index: baseCounter)
        if autoSelectExecuted == true {
            self.delegate?.categoryNameChanged(index: baseCounter)
        } else {
            autoSelectExecuted = true
        }
        baseCounter += 1
        
        if !showTimer.isValid {
            showCounter = 0
            showTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(showAction(timer:)), userInfo: ["array" :array], repeats: true)
        }
        
        task?.cancel()
        task = DispatchWorkItem {
            if !self.hideTimer.isValid {
                self.hideCounter = 0
                self.hideTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.hideAction(timer:)), userInfo: ["array" :array], repeats: true)
            }
        }
        
        let delayInSeconds = 12.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds, execute: task!)
    }

    
    @objc func showAction(timer: Timer) {
        if !self.showTimer.isValid || isResetExecuted {
            return
        }
        if let userInfo = timer.userInfo as? Dictionary<String, AnyObject>, let infoLabelarray = (userInfo["array"] as? Array<UILabel>), infoLabelarray.count > 0 {
           // self.showCategoryNameLabel(label: CategoryInfoLabel ?? UILabel())
            if showCounter < infoLabelarray.count {
                let label = infoLabelarray[showCounter]
                self.showLabel(label : label, counter: showCounter)
                showCounter += 1
            }
            else {
                self.invalidateTimer()
            }
        }
    }
    
    func showLabel(label : UILabel, counter: Int) {
        if isResetExecuted { return }
        label.alpha = 1.0
        
        var labelFrame = label.frame
        //labelFrame.origin.y = self.frame.size.height + 100 - Bottom to Top
        labelFrame.origin.x = self.frame.size.width + 50 // - Left to Right
        label.frame = labelFrame
        label.alpha = 0.0
        UIView.animate(withDuration: 0.8, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            //labelFrame.origin.y = CGFloat(self.infoLabelPositionarray[counter]) - Bottom to Top
            labelFrame.origin.x = 26 // - Left to Right
            label.frame = labelFrame
            label.alpha = 1.0

        }, completion:{(finished : Bool)  in
            if (finished) {
                // Label shake animation added
                   label.shake(duration: 1.0)
                // Check with pooms then desire
                //label.layer.shakeAnimationLabel(duration:  TimeInterval(2.0))
            }
        })

    }

    @objc func hideAction(timer: Timer) {
        if !self.hideTimer.isValid || isResetExecuted {
            return
        }
        if let userInfo = timer.userInfo as? Dictionary<String, AnyObject>, let infoLabelarray = (userInfo["array"] as? Array<UILabel>), infoLabelarray.count > 0 {
            //self.hideCategoryNameLabel(label: self.CategoryInfoLabel ?? UILabel())
            if hideCounter < infoLabelarray.count {
                let label = infoLabelarray[hideCounter]
                self.hideLabel(label : label, counter: hideCounter)
                hideCounter += 1
            }
            else {
                self.invalidateTimer()
            }
        }
    }

    func hideLabel(label : UILabel, counter: Int) {
        if isResetExecuted { return }
        label.alpha = 1.0
        var labelFrame = label.frame
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            //labelFrame.origin.y = 150  - Bottom to Top
            labelFrame.origin.x = -450 // - Left to Right
            label.frame = labelFrame
            label.alpha = 0.0
        }, completion: nil)
    }

    
    /*
     Invalidate timer
     */
    func invalidateTimer() {
        isResetExecuted = false
//        baseCounter = 0
//        hideCounter = 0
        showTimer.invalidate()
        hideTimer.invalidate()
    }

    func invalidateAllTimer() {
        isResetExecuted = true
        for array in infoBasearray {
            for label in array {
                label.alpha = 0.0
            }
        }
        baseCounter = -1
        hideCounter = -1
        baseTimer.invalidate()
        showTimer.invalidate()
        hideTimer.invalidate()
        task?.cancel()
    }

    func restartBaseTimer()  {
        baseTimer.invalidate()
        self.autoSelectExecuted = true
        baseTimer = Timer.scheduledTimer(timeInterval: 14.5, target: self, selector: #selector(animateBoard), userInfo: nil, repeats: true)
    }

    func formatPoint18Text(text: String) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name:"HelveticaNeue", size:17.0) ?? UIFont.systemFont(ofSize: 17.0), range: attributedString.string.fullrange() )
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 0.8, range: NSMakeRange(0, text.count))
        return attributedString
    }

}

     /*
     // Label shake animation added
     */
public extension UILabel {

    func shake(duration: CFTimeInterval) {
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        translation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        translation.values = [-6, 6, 0, 0]//-6,6,0
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        shakeGroup.animations = [translation]
        shakeGroup.duration = duration
        self.layer.add(shakeGroup, forKey: "shakeIt")
    }

    func shakeXPosition(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count ?? 2
        animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? -5
        layer.add(animation, forKey: "shake")
    }
}


extension CALayer {
    
    func shakeAnimationLabel(duration: TimeInterval = TimeInterval(0.5)) {
        let animationKey = "shake"
        removeAnimation(forKey: animationKey)
        let kAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        kAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        kAnimation.duration = duration
        // Adjust the speed of label
        var needOffset = (frame.width * 0.06),
        values = [CGFloat]()
        
        let minOffset = needOffset * 0.1
        
        repeat {
            
            values.append(-needOffset)
            values.append(needOffset)
            needOffset *= 0.5
        } while needOffset > minOffset
        
        values.append(0)
        kAnimation.values = values
        add(kAnimation, forKey: animationKey)
    }
}


extension SiriContentView: categoryNameDelegate {
    
    func setupScroll() {
        // CategoyName animate Delegate set
         delegate = self
        if let _items = self.getCategoryNames(), _items.count > 0 {
            items = _items
            itemsViews = _items.map { labelForString($0) }
            categoryNameCarousel.items = itemsViews!
            categoryNameCarousel.resizeType = .floatWithSpacing(20)//.visibleItemsPerPage(3)
            categoryNameCarousel.defaultSelectedIndex = 0
            categoryNameCarousel.delegate = self
            categoryNameCarousel.scrollType = .default
            categoryNameCarousel.scrollView.setContentOffset(CGPoint.init(x: categoryNameCarousel.scrollView.contentOffset.x - 10, y: 0), animated: false)
        }
    }
    
    func labelForString(_ string: String?) -> UILabel {
        let text = UILabel(frame: CGRect.init(x: 0, y: 0, width: 125.0, height: 24))
        text.text = string ?? ""
        text.textColor = .black
        text.textAlignment = .center
        text.numberOfLines = 1
        text.backgroundColor = UIColor.clear
        return text
    }
    
    func textViewDidChangeAction(with textView: InputTextView) { }
    func keyboardSwipeGestureAction(with gesture: UISwipeGestureRecognizer) { }
    func keyboardEditingEndsAction() { }
    func keyboardEditingBeginsAction() { }

}


extension SiriContentView: SwiftCarouselDelegate {
    
    func didSelectItem(item: UIView, index: Int, tapped: Bool, autoSelected: Bool) -> UIView? {
        self.deselectAll()
        if let animal = item as? UILabel {
            animal.textColor = UIColor.black
            self.autoSelectExecuted = autoSelected
            if let _items = items, _items.count > 0 && !autoSelected {
                self.showSelectedCategory(name: animal.text ?? "")
            }
            return animal
        }
        return item
    }
    
    func didDeselectItem(item: UIView, index: Int) -> UIView? {
        if let animal = item as? UILabel {
            animal.textColor =  UIColor.lightGray
            return animal
        }
        self.deselectAll()
        return item
    }
    
    func didScroll(toOffset offset: CGPoint, _ scrollView: UIScrollView? = nil) {
        self.deselectAll()
    }
    
    func willBeginDragging(withOffset offset: CGPoint) {
    }
    
    func didEndDragging(withOffset offset: CGPoint) {
    }
    
    func showSelectedCategory(name: String) {
        if let _items = items, _items.count > 0 {
            let indexOfName = _items.firstIndex(of: name)
            self.invalidateAllTimer()
            self.baseCounter = indexOfName ?? 0
            self.animateBoard()
            self.restartBaseTimer()
        }
    }
    
    func deselectAll() {
        let scrollView: UIScrollView? = categoryNameCarousel.scrollView
        if let _scrollView = scrollView, let _items = items, _items.count > 0 {
            for subview in _scrollView.subviews {
                if let label = subview as? UILabel {
                    label.textColor = UIColor.lightGray
                }
            }
        }
    }
    
    func categoryNameChanged(index: Int) {
        if let _items = items, _items.count > 0 {
            for subview in categoryNameCarousel.scrollView.subviews {
                if let label = subview as? UILabel {
                    let indexOfName = _items.firstIndex(of: label.text ?? "")
                    if indexOfName == index {
                        categoryNameCarousel.viewAutoselected(view: label)
                        label.textColor = UIColor.black
                        break
                    }
                }
            }
        }
    }
}
