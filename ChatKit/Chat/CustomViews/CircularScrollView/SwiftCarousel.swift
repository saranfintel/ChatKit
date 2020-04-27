//
//  SwiftCarousel.swift
//  CircularScroll
//
//  Created by Poomalai on 11/22/17.
//  Copyright © 2017 Clover. All rights reserved.
//
//https://github.com/DroidsOnRoids/SwiftCarousel

import UIKit

public enum ArchiveCopyingError: Error {
    case view
}

public extension UIView {
    fileprivate func prepareConstraintsForArchiving() {
        constraints.forEach { $0.shouldBeArchived = true }
        subviews.forEach { $0.prepareConstraintsForArchiving() }
    }
    
    /**
     Method to copy UIView using archivizing.
     
     - returns: Copied UIView (different memory address than current)
     */
    public func copyView() throws -> UIView {
        prepareConstraintsForArchiving()
        guard let view = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? UIView else { throw ArchiveCopyingError.view }
        return view
    }
}


/// Enum to indicate resize type Carousel will be using.
public enum SwiftCarouselResizeType {
    /// WithoutResizing is adding frames as they are.
    /// Parameter = spacing between UIViews.
    /// !!You need to pass correct frame sizes as items!!
    case withoutResizing(CGFloat)
    
    /// VisibleItemsPerPage will try to fit the number of items you specify
    /// in the whole screen (will resize them of course).
    /// Parameter = number of items visible on screen.
    case visibleItemsPerPage(Int)
    
    /// FloatWithSpacing will use sizeToFit() on your views to correctly place images
    /// It is helpful for instance with UILabels (Example1 in Examples folder).
    /// Parameter = spacing between UIViews.
    case floatWithSpacing(CGFloat)
}

public func ==(lhs: SwiftCarouselScroll, rhs: SwiftCarouselScroll) -> Bool {
    return true//String(stringInterpolationSegment: lhs) == String(stringInterpolationSegment: rhs)
}

/// Type for defining if the carousel should be constrained when scrolling.
public enum SwiftCarouselScroll: Equatable {
    /// .Default = .Freely
    case `default`
    /// Set maximum number of items that user can scroll
    /// If you pass 0, it will be set to .None.
    case max(UInt)
    /// Don't allow scrolling.
    case none
    /// Doesn't limit the scroll at all. You can scroll how far you want.
    case freely
    /// TODO:
    // Set exact amount of items per scroll.
    // case Amount(UInt)
}


@objc public protocol SwiftCarouselDelegate {
    /**
     Delegate method that fires up when item has been selected.
     If there was an animation, it fires up _after_ animation.
     Warning! Do not rely on item to get index from your data source.
     Index is passed as a variable in that function and you should use it instead.
     
     - parameter item:  Item that is selected. You can style it as you want.
     - parameter index: Index of selected item that you can use with your data source.
     - parameter tapped: Indicate that the item has been tapped, true it means that it was tapped before the selection, and false that was scrolled.
     
     - returns: Return UIView that you customized (or not).
     */
    @objc optional func didSelectItem(item: UIView, index: Int, tapped: Bool, autoSelected: Bool) -> UIView?
    
    /**
     Delegate method that fires up when item has been deselected.
     If there was an animation, it fires up _after_ animation.
     Warning! Do not rely on item to get index from your data source.
     Index is passed as a variable in that function and you should use it instead.
     
     - parameter item:  Item that is deselected. You can style it as you want.
     - parameter index: Index of deselected item that you can use with your data source.
     
     - returns: Return UIView that you customized (or not).
     */
    @objc optional func didDeselectItem(item: UIView, index: Int) -> UIView?
    
    /**
     Delegate method that fires up when Carousel has been scrolled.
     
     - parameter offset: New offset of the Carousel.
     */
    @objc optional func didScroll(toOffset offset: CGPoint, _ scrollView: UIScrollView?)
    /**
     Delegate method that fires up just before someone did dragging.
     
     - parameter offset: Current offset of the Carousel.
     */
    @objc optional func willBeginDragging(withOffset offset: CGPoint)
    /**
     Delegate method that fires up right after someone did end dragging.
     
     - parameter offset: New offset of the Carousel.
     */
    @objc optional func didEndDragging(withOffset offset: CGPoint)
}


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


open class SwiftCarousel: UIView {
    //MARK: - Properties
    
    open var itemAutoSelected = false

    /// Current target with velocity left
    internal var currentVelocityX: CGFloat?
    /// Maximum velocity that swipe can reach.
    internal var maxVelocity: CGFloat = 100.0
    // Bool to know if item has been selected by Tapping
    fileprivate var itemSelectedByTap = false
    /// Number of items that were set at the start of init.
    fileprivate var originalChoicesNumber = 0
    /// Items that carousel shows. It is 3x more items than originalChoicesNumber.
    open var choices: [UIView] = []
    /// Main UIScrollView.
    open var scrollView = UIScrollView()
    /// Current selected index (between 0 and choices count).
    open var currentSelectedIndex: Int?
    /// Current selected index (between 0 and originalChoicesNumber).
    open var currentRealSelectedIndex: Int?
    /// Carousel delegate that handles events like didSelect.
    open weak var delegate: SwiftCarouselDelegate?
    /// Bool to set if by tap on item carousel should select it (scroll to it).
    open var selectByTapEnabled = true
    /// Scrolling type of carousel. You can constraint scrolling through items.
    open var scrollType: SwiftCarouselScroll = .default {
        didSet {
            if case .max(let number) = scrollType , number <= 0 {
                scrollType = .none
            }
            
            switch scrollType {
            case .none:
                scrollView.isScrollEnabled = false
            case .max, .freely, .default:
                scrollView.isScrollEnabled = true
            }
        }
    }
    
    
    /// Resize type of the carousel chosen from SwiftCarouselResizeType.
    open var resizeType: SwiftCarouselResizeType = .withoutResizing(0.0) {
        didSet {
            setupViews(choices)
        }
    }
    /// If selected index is < 0, set it as nil.
    /// We won't check with count number since it might be set before assigning items.
    open var defaultSelectedIndex: Int? {
        didSet {
            if (defaultSelectedIndex < 0) {
                defaultSelectedIndex = nil
            }
        }
    }
    /// If there is defaultSelectedIndex and was selected, the variable is true.
    /// Otherwise it is not.
    open var didSetDefaultIndex: Bool = false
    /// Current selected index (calculated by searching through views),
    /// It returns index between 0 and originalChoicesNumber.
    open var selectedIndex: Int? {
        let view = viewAtLocation(CGPoint(x: scrollView.contentOffset.x + scrollView.frame.width / 2.0, y: scrollView.frame.minY))
        guard var index = choices.index(where: { $0 == view }) else {
            return nil
        }
        
        while index >= originalChoicesNumber {
            index -= originalChoicesNumber
        }
        
        return index
    }
    /// Current selected index (calculated by searching through views),
    /// It returns index between 0 and choices count.
    open var realSelectedIndex: Int? {
        let view = viewAtLocation(CGPoint(x: scrollView.contentOffset.x + scrollView.frame.width / 2.0, y: scrollView.frame.minY))
        guard let index = choices.index(where: { $0 == view }) else {
            return nil
        }
        
        return index
    }
    /// Carousel items. You can setup your carousel using this method (static items), or
    /// you can also see `itemsFactory`, which uses closure for the setup.
    /// Warning: original views are copied internally and are not guaranteed to be complete when the `didSelect` and `didDeselect` delegate methods are called. Use `itemsFactory` instead to avoid this limitation.
    open var items: [UIView] {
        get {
            return [UIView](choices[choices.count / 3..<(choices.count / 3 + originalChoicesNumber)])
        }
        set {
            originalChoicesNumber = newValue.count
            (0..<3).forEach { counter in
                let newViews: [UIView] = newValue.map { choice in
                    // Return original view if middle section
                    if counter == 1 {
                        return choice
                    } else {
                        do {
                            return try choice.copyView()
                        } catch {
                            fatalError("There was a problem with copying view.")
                        }
                    }
                }
                self.choices.append(contentsOf: newViews)
            }
            setupViews(choices)
        }
    }
    
    /// Factory for carousel items. Here you specify how many items do you want in carousel
    /// and you need to specify closure that will create that view. Remember that it should
    /// always create new view, not give the same reference all the time.
    /// If the factory closure returns a reference to a view that has already been returned, a SwiftCarouselError.ViewAlreadyAdded error is thrown.
    /// You can always setup your carousel using `items` instead.
    open func itemsFactory(itemsCount count: Int, factory: (_ index: Int) -> UIView) throws {
        guard count > 0 else { return }
        
        originalChoicesNumber = count
        try (0..<3).forEach { counter in
            let newViews: [UIView] = try stride(from: 0, to: count, by: 1).map { i in
                let view = factory(i)
                guard !self.choices.contains(view) else {
                    throw SwiftCarouselError.viewAlreadyAdded
                }
                return view
            }
            self.choices.append(contentsOf: newViews)
        }
        setupViews(choices)
    }
    
    // MARK: - Inits
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /**
     Initialize carousel with items & frame.
     
     - parameter frame:   Carousel frame.
     - parameter items: Items to put in carousel.
     
     Warning: original views in `items` are copied internally and are not guaranteed to be complete when the `didSelect` and `didDeselect` delegate methods are called. Use `itemsFactory` instead to avoid this limitation.
     
     */
    public convenience init(frame: CGRect, items: [UIView]) {
        self.init(frame: frame)
        setup()
        self.items = items
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // MARK: - Setups
    
    /**
     Main setup function. Here should be everything that needs to be done once.
     */
    fileprivate func setup() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|",
                                                      options: .alignAllCenterX,
                                                      metrics: nil,
                                                      views: ["scrollView": scrollView])
        )
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|",
                                                      options: .alignAllCenterY,
                                                      metrics: nil,
                                                      views: ["scrollView": scrollView])
        )
        
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    /**
     Setup views. Function that is fired up when setting the resizing type or items array.
     
     - parameter views: Current items to setup.
     */
    fileprivate func setupViews(_ views: [UIView]) {
        var x: CGFloat = 0.0
        if case .floatWithSpacing(_) = resizeType {
            views.forEach { $0.sizeToFit() }
        }
        
        views.forEach { choice in
            var additionalSpacing: CGFloat = 0.0 // TEST
            switch resizeType {
            case .withoutResizing(let spacing): additionalSpacing = spacing
            case .floatWithSpacing(let spacing): additionalSpacing = spacing
            case .visibleItemsPerPage(let visibleItems):
                choice.frame.size.width = UIScreen.main.bounds.width / CGFloat(visibleItems)
                if (choice.frame.height > 0.0) {
                    let aspectRatio: CGFloat = choice.frame.width/choice.frame.height
                    choice.frame.size.height = floor(choice.frame.width * aspectRatio) > frame.height ? frame.height : floor(choice.frame.width * aspectRatio)
                } else {
                    choice.frame.size.height = frame.height
                }
            }
            choice.frame.origin.x = x
            x += choice.frame.width + additionalSpacing
        }
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.subviews.forEach { $0.backgroundColor = .green }
        views.forEach { scrollView.addSubview($0) }
        layoutIfNeeded()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        guard (scrollView.frame.width > 0 && scrollView.frame.height > 0)  else { return }
        
        var width: CGFloat = 0.0
        switch resizeType {
        case .floatWithSpacing(_), .withoutResizing(_):
            width = (choices.count > 0) ? (choices.last?.frame.maxX ?? 0) : 0
        case .visibleItemsPerPage(_):
            width = choices.reduce(0.0) { $0 + $1.frame.width }
        }
        
        scrollView.contentSize = CGSize(width: width, height: frame.height)
        maxVelocity = scrollView.contentSize.width / 6.0
        
        // We do not want to change the selected index in case of hiding and
        // showing view, which also triggers layout.
        // On the other hand this method can be triggered when the defaultSelectedIndex
        // was set after the carousel init, so we check if the default index is != nil
        // and that it wasn't set before.
        guard currentSelectedIndex == nil ||
            (didSetDefaultIndex == false && defaultSelectedIndex != nil) else { return }
        
        // Center the view
        if defaultSelectedIndex != nil {
            selectItem(defaultSelectedIndex!, animated: false)
            didSetDefaultIndex = true
        } else {
            selectItem(0, animated: false)
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = change?[NSKeyValueChangeKey.newKey] , keyPath == "contentOffset" {
            // with autolayout this seems to be quite usual, we want to wait
            // until we have some size we can actualy work with
            guard (scrollView.frame.width > 0 &&
                scrollView.frame.height > 0)  else { return }
            
            let newOffset = scrollView.contentOffset
            let segmentWidth = scrollView.contentSize.width / 3
            var newOffsetX: CGFloat!
            if (newOffset.x >= segmentWidth * 2.0) { // in the 3rd part
                newOffsetX = newOffset.x - segmentWidth // move back one segment
            } else if (newOffset.x + scrollView.bounds.width) <= segmentWidth { // First part
                newOffsetX = newOffset.x + segmentWidth // move forward one segment
            }
            // We are in middle segment still so no need to scroll elsewhere
            guard newOffsetX != nil && newOffsetX > 0 else {
                return
            }
            
            self.scrollView.contentOffset.x = newOffsetX
            
            self.delegate?.didScroll?(toOffset: self.scrollView.contentOffset, self.scrollView)
        }
    }
    
    // MARK: - Gestures
    @objc open func viewTapped(_ gestureRecognizer: UIGestureRecognizer) {
        if selectByTapEnabled {
            let touchPoint = gestureRecognizer.location(in: scrollView)
            if let view = viewAtLocation(touchPoint), let index = choices.index(of: view) {
                itemSelectedByTap = true
                itemAutoSelected = false
                selectItem(index, animated: true, force: true)
            }
        }
    }
    
    @objc open func viewAutoselected(view: UILabel) {
        if let index = choices.index(of: view) {
            itemAutoSelected = true
            selectItem(index, animated: false, force: true, autoSelect: true)
        }
    }

    // MARK: - Helpers
    
    /**
     Function that should be called when item was selected by Carousel.
     It will deselect all items that were selected before, and send
     notification to the delegate.
     */
    internal func didSelectItem() {
        guard let selectedIndex = self.selectedIndex, let realSelectedIndex = self.realSelectedIndex else {
            return
        }
        
        let choiceView = choices[realSelectedIndex]
        let x = choiceView.center.x - scrollView.frame.width / 2.0
        
        let newPosition = CGPoint(x: x, y: scrollView.contentOffset.y)
        scrollView.setContentOffset(newPosition, animated: true)

        
        didDeselectItem()
      //  if itemAutoSelected == false {
            _ = delegate?.didSelectItem?(item: choices[realSelectedIndex], index: selectedIndex, tapped: itemSelectedByTap, autoSelected: itemAutoSelected)
        //}
        itemSelectedByTap = false
        currentSelectedIndex = selectedIndex
        currentRealSelectedIndex = realSelectedIndex
        currentVelocityX = nil
        scrollView.isScrollEnabled = true
    }
    
    /**
     Function that should be called when item was deselected by Carousel.
     It will also send notification to the delegate.
     */
    internal func didDeselectItem() {
        guard let currentRealSelectedIndex = self.currentRealSelectedIndex, let currentSelectedIndex = self.currentSelectedIndex else {
            return
        }
        
        _ = delegate?.didDeselectItem?(item: choices[currentRealSelectedIndex], index: currentSelectedIndex)
    }
    
    /**
     Detects if new point to scroll to will change the part (from the 3 parts used by Carousel).
     First and third parts are not shown to the end user, we are managing the scrolling between
     them behind the stage. The second part is the part user thinks it sees.
     
     - parameter point: Destination point.
     
     - returns: Bool that says if the part will change.
     */
    fileprivate func willChangePart(_ point: CGPoint) -> Bool {
        if (point.x >= scrollView.contentSize.width * 2.0 / 3.0 ||
            point.x <= scrollView.contentSize.width / 3.0) {
            return true
        }
        
        return false
    }
    
    /**
     Get view (from the items array) at location (if it exists).
     
     - parameter touchLocation: Location point.
     
     - returns: UIView that contains that point (if it exists).
     */
    fileprivate func viewAtLocation(_ touchLocation: CGPoint) -> UIView? {
        for subview in scrollView.subviews where subview.frame.contains(touchLocation) {
            return subview
        }
        
        return nil
    }
    
    /**
     Get nearest view to the specified point location.
     
     - parameter touchLocation: Location point.
     
     - returns: UIView that is the nearest to that point (or contains that point).
     */
    internal func nearestViewAtLocation(_ touchLocation: CGPoint) -> UIView {
        var view: UIView!
        if let newView = viewAtLocation(touchLocation) {
            view = newView
        } else {
            // Now check left and right margins to nearest views
            var step: CGFloat = 1.0
            
            switch resizeType {
            case .floatWithSpacing(let spacing):
                step = spacing
            case .withoutResizing(let spacing):
                step = spacing
            default:
                break
            }
            
            var targetX = touchLocation.x
            
            // Left
            var leftView: UIView?
            
            repeat {
                targetX -= step
                leftView = viewAtLocation(CGPoint(x: targetX, y: touchLocation.y))
            } while (leftView == nil)
            
            let leftMargin = touchLocation.x - leftView!.frame.maxX
            
            // Right
            var rightView: UIView?
            
            repeat {
                targetX += step
                rightView = viewAtLocation(CGPoint(x: targetX, y: touchLocation.y))
            } while (rightView == nil)
            
            let rightMargin = rightView!.frame.minX - touchLocation.x
            
            if rightMargin < leftMargin {
                
                view = rightView!
            } else {
                view = leftView!
            }
        }
        
        // Check if the view is in bounds of scrolling type
        if case .max(let maxItems) = scrollType,
            let currentRealSelectedIndex = currentRealSelectedIndex,
            var newIndex = choices.index (where: { $0 == view }) {
            
            if UInt(abs(newIndex - currentRealSelectedIndex)) > maxItems {
                if newIndex > currentRealSelectedIndex {
                    newIndex = currentRealSelectedIndex + Int(maxItems)
                } else {
                    newIndex = currentRealSelectedIndex - Int(maxItems)
                }
            }
            
            while newIndex < 0 {
                newIndex += originalChoicesNumber
            }
            
            while newIndex > choices.count {
                newIndex -= originalChoicesNumber
            }
            
            view = choices[newIndex]
        }
        
        return view
    }
    
    /**
     Select item in the Carousel.
     
     - parameter choice:   Item index to select. If it contains number > than originalChoicesNumber,
     you need to set `force` flag to true.
     - parameter animated: If the method should try to animate the selection.
     - parameter force:    Force should be set to true if choice index is out of items bounds.
     */
    open func selectItem(_ choice: Int, animated: Bool, force: Bool, autoSelect: Bool = false) {
        var index = choice
        if !force {
            // allow scroll only in the range of original items
            guard choice < choices.count / 3 else {
                return
            }
            // move to same item in middle segment
            index = index + originalChoicesNumber
        }
        
        let choiceView = choices[index]
        let x = choiceView.center.x - scrollView.frame.width / 2.0
        
        let newPosition = CGPoint(x: x, y: scrollView.contentOffset.y)
        let animationIsNotNeeded = newPosition.equalTo(scrollView.contentOffset)
        scrollView.setContentOffset(newPosition, animated: animated)
        if (!animated || animationIsNotNeeded) {//}&& !autoSelect {
            didSelectItem()
        }
    }
    
    /**
     Select item in the Carousel.
     
     - parameter choice:   Item index to select.
     - parameter animated: Bool to tell if the selection should be animated.
     
     */
    open func selectItem(_ choice: Int, animated: Bool) {
        selectItem(choice, animated: animated, force: false)
    }
}

extension SwiftCarousel: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension SwiftCarousel: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didSelectItem()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didSelectItem()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        itemAutoSelected = false
        delegate?.willBeginDragging?(withOffset: scrollView.contentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        itemAutoSelected = false
        delegate?.didEndDragging?(withOffset: scrollView.contentOffset)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        itemAutoSelected = false
        var velocity = velocity.x * 300.0
        
        var targetX = scrollView.frame.width / 2.0 + velocity
        
        // When the target is being scrolled and we scroll again,
        // the position we need to take as base should be the destination
        // because velocity will stay and if we will take the current position
        // we won't get correct item because the X distance we skipped in the
        // last circle wasn't included in the calculations.
        if let oldTargetX = currentVelocityX {
            targetX += (oldTargetX - scrollView.contentOffset.x)
        } else {
            targetX += scrollView.contentOffset.x
        }
        
        if velocity >= maxVelocity {
            velocity = maxVelocity
        } else if velocity <= -maxVelocity {
            velocity = -maxVelocity
        }
        
        if (targetX > scrollView.contentSize.width || targetX < 0.0) {
            targetX = scrollView.contentSize.width / 3.0 + velocity
        }
        
        let choiceView = nearestViewAtLocation(CGPoint(x: targetX, y: scrollView.frame.minY))
        let newTargetX = choiceView.center.x - scrollView.frame.width / 2.0
        currentVelocityX = newTargetX
        targetContentOffset.pointee.x = newTargetX
        if case .max(_) = scrollType {
            scrollView.isScrollEnabled = false
        }
    }
}

// ErrorType enum for the potential errors thrown by SwiftCarousel
enum SwiftCarouselError: Error {
    case viewAlreadyAdded // thrown when returning a view that has already been added to the carousel previously from the item factory closure
    // TODO: Add BadNumberOfItems, when using selectItem or scrollType = .Max(UInt)
}
