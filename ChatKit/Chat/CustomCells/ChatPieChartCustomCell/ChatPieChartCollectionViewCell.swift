//
//  ChatPieChartCollectionViewCell.swift
//  ChatApp
//
//  Created by pooma on 12/23/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import MessageKit

class ChatPieChartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewMessageWithPieChart: UIView?
    @IBOutlet weak var pieChartView : UIView?
    @IBOutlet weak var pieChartViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var avatarlabel: ChatLabel!

    let chart = VBPieChart();
    var transactionResponse: Transactions? = nil

    override open func awakeFromNib() {
        super.awakeFromNib()
        if let icon = ChatSession.receiveIcon() {
            self.avatarIcon.image = icon
            self.avatarIcon.isHidden = false
        } else {
            self.avatarlabel.text = ChatSession.receiveTitle()
            self.avatarlabel.isHidden = false
        }
    }
    
    func configurationCell(message: ChatDBMessage) {
        guard let transactionsMessage = message.kind else {
            return
        }
        dateLabel?.text = message.postedAt?.dateToTimeFormat(withFormat: timeFormat)
        transactionResponse = Transactions.Map(transactionsMessage)
        if !chart.isDescendant(of: pieChartView ?? UIView()) {
            pieChartView?.addSubview(addPieChart())
        }
    }
    
    func addPieChart() -> UIView {
        let size = (self.frame.size.width > 320.0) ? CGFloat(270) : CGFloat(200)
        pieChartViewHeightConstraint?.constant = size
        let x = (self.frame.size.width > 320.0) ? CGFloat(self.frame.size.width - size)/2 : CGFloat(45.0)
        chart.frame = CGRect(x: x - 10, y: 10, width: size, height: size);
        chart.holeRadiusPrecent = 0.3;
        chart.center = CGPoint.init(x: (pieChartView?.frame.size.width ?? 0)/2 , y: ((pieChartView?.frame.size.height ?? 0)/2))
        
        //iPad changes
        if UIDevice.current.userInterfaceIdiom == .pad {
            let x1 = CGFloat(45.0)
            chart.frame = CGRect(x: x1, y: 0, width: size, height: size);
        }
        let chartColorValues = [UIColor(hexString:"dd191daa"), UIColor(hexString:"d81b60aa"), UIColor(hexString:"8e24aaaa"), UIColor(hexString:"3f51b5aa"), UIColor(hexString:"5677fcaa")]
        
        var chartValues = [Dictionary<String, Any>]()
        let spendData = transactionResponse?.spendData ?? []
        var index = 0
        for _data in spendData {
            let value = (round(_data.value*100)) / 100.0;
            chartValues.append(["name":_data.category.emojiUnescapedString , "showAmount": true, "value": value, "color":chartColorValues[index] ?? UIColor.red])
            index += 1
        }
        
        chart.setChartValues(chartValues as [AnyObject], animation:true);
        pieChartView?.layer.cornerRadius = 25.0
        pieChartView?.backgroundColor = UIColor.colorFromHex(hexString: "#e6e6e6")

        return chart
    }

    deinit {
        transactionResponse = nil
    }
}
