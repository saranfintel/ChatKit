//
//  ChatBarChartCollectionViewCell.swift
//  ChatApp
//
//  Created by pooma on 12/23/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import MessageKit

class ChatBarChartCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewMessageWithChart: UIView?
    @IBOutlet weak var barChartView : ChatBubbleView!
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var avatarlabel: ChatLabel!
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!

    var graphView = ScrollableGraphView()
    var currentGraphType = GraphType.dark
    var label = UILabel()
    var labelConstraints = [NSLayoutConstraint]()
    lazy var data: [Double] = {
        var _graphData = [Double]()
        let averageData = transactionResponse?.spendData ?? []
        for _data in averageData {
            _graphData.append(Double(_data.value))
        }
        return _graphData
    }()
    lazy var labels: [String] = {
        var _graphData = [String]()
        let averageData = transactionResponse?.spendData ?? []
        for _data in averageData {
            let category = _data.category.replacingOccurrences(of: "and", with: "&")
            _graphData.append(category)
        }
        return _graphData
    }()
    var transactionResponse: Transactions? = nil

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
        currentGraphType = GraphType.bar
        graphView = createBarGraph(barChartView.frame)
    }
    func configurationCell(message: ChatDBMessage) {
        guard let transactionsMessage = message.kind else {
            return
        }
        bubbleWidthConstraint.constant = UIDevice().chatViewMaxWidth
        self.layoutIfNeeded()
        dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)
        transactionResponse = Transactions.Map(transactionsMessage)
        self.updateBarChartMessage()
    }
    /* DisplayType - messageWithChart */
    func updateBarChartMessage() {
        viewMessageWithChart?.isHidden = false
        graphView.set(data: data, withLabels: labels)
        graphView.frame = CGRect.init(x: 5, y: 10, width: barChartView.frame.size.width - 10, height: barChartView.frame.size.height - 20)
        barChartView.addSubview(graphView)
        graphView.backgroundColor = UIColor.colorFromHex(hexString: "#e6e6e6")
        barChartView.layoutSubviews()
    }
    private func createBarGraph(_ frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame:frame)
        graphView.dataPointType = ScrollableGraphViewDataPointType.circle
        graphView.shouldDrawBarLayer = true
        graphView.shouldDrawDataPoint = false
        
        graphView.lineColor = UIColor.clear
        graphView.barWidth = 15
        graphView.barLineWidth = 1
        graphView.barLineColor = UIColor.colorFromHex(hexString: "#777777")
        graphView.barColor = UIColor.white
        graphView.backgroundFillColor = UIColor.clear
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        graphView.referenceLineLabelColor = UIColor.black
        graphView.numberOfIntermediateReferenceLines = 5
        graphView.dataPointLabelColor = UIColor.black
        graphView.leftLabelInset = 5
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        graphView.animationDuration = 1.5
        graphView.rangeMax = 50
        graphView.dataPointSpacing = (self.frame.size.width > 320) ? 44 : 34
        if UIDevice.current.userInterfaceIdiom == .pad { graphView.dataPointSpacing = 120 }
        graphView.shouldRangeAlwaysStartAtZero = true
        return graphView
    }
    // The type of the current graph we are showing.
    enum GraphType {
        case dark
        case bar
        case dot
        case pink
        
        mutating func next() {
            switch(self) {
            case .dark:
                self = GraphType.bar
            case .bar:
                self = GraphType.dot
            case .dot:
                self = GraphType.pink
            case .pink:
                self = GraphType.dark
            }
        }
    }
}
