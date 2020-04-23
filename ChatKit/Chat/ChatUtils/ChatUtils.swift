//
//  ChatUtils.swift
//  ChatApp
//
//  Created by pooma on 12/23/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation
import MessageKit


struct ChatUtils {
    
    /*static func getFont(of name: String,of size: CGFloat) -> UIFont {
        return UIFont(name:name, size:size) ?? UIFont.systemFont(ofSize: size)
    }

    public static func formatStaticText(text: String) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: text)
        //Add spacing 0.5
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 0.5, range: NSMakeRange(0, text.count))
        return attributedString
    }
    
    public static func formatAmount(amount: String) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: amount)
        //Add spacing 1.0
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 1.0, range: NSMakeRange(0, amount.count))
        
        return attributedString
    }
    
    public static func formatPoint8Text(text: String) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: text)
        //Add spacing 0.8
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 0.8, range: NSMakeRange(0, text.count))
        return attributedString
    }

    public static func formatAmountWithFont(amount: String) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: amount)
        //Add spacing 1.0
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 1.0, range: NSMakeRange(0, amount.count))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name:"HelveticaNeue-Light", size:15.0)! , range: attributedString.string.fullrange() )
        return attributedString
    }

    public static func formatAmountWithBoldFont(amount: String) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: amount)
        //Add spacing 1.0
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 1.0, range: NSMakeRange(0, amount.count))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name:"HelveticaNeue-Bold", size:15.0)! , range: attributedString.string.fullrange() )
        
        return attributedString
    }

    //Card recommendation & display notes only... Don't use for others
    public static func stringMediumFontFromHtml(string: String) -> NSAttributedString? {
        if let data = string.data(using: String.Encoding.unicode, allowLossyConversion: true) {
            let attrStr = try? NSMutableAttributedString(data: data, options: [ .documentType: NSAttributedString.DocumentType.html],documentAttributes: nil)
            let rangeStr = attrStr?.mutableString.range(of: attrStr?.string ?? "", options:NSString.CompareOptions.caseInsensitive)
            // adding font
            attrStr?.addAttribute(NSAttributedString.Key.font, value: UIFont(name:"HelveticaNeue-Medium", size:17.0) ?? UIFont.systemFont(ofSize: 17.0), range: rangeStr ?? NSMakeRange(0, 0))
             //adding color
            attrStr?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.colorFromHex(hexString: "#4A4A4A") , range: rangeStr ?? NSMakeRange(0, 0))
            //Add spacing 1.0
            attrStr?.addAttribute(NSAttributedString.Key.kern, value: 1.0, range: rangeStr ?? NSMakeRange(0, 0))            
            return attrStr
        }
        return nil
    }*/

}


extension ChatUtils {
    
    public static func findDisplayType(displayType: String? = nil) {
        
        let displayType = displayType ?? "" //ChatDataController.sharedInstance.transactionResponse?.transactionsHeader?.display_type ?? ""
        switch displayType {
        case DisplayType.messageWithAmountTransactions.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithAmountTransactions
        case DisplayType.messageWithGraphTransactions.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithGraphTransactions
        case DisplayType.messageWithBarTransactions.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithBarTransactions
        case DisplayType.messageWithPieTransactions.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithPieTransactions
        case DisplayType.accountTransactions.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .accountTransactions
        case DisplayType.messageWithTransaction.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithTransaction
        case DisplayType.message.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .message
        case DisplayType.messageWithAmount.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithAmount
        case DisplayType.messageWithNotes.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithNotes
        case DisplayType.messageWithError.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithError
        case DisplayType.messageWithGraph.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithGraph
        case DisplayType.messageWithChart.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithChart
        case DisplayType.messageWithPieChart.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .messageWithPieChart
        case DisplayType.cardRecommendation.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .cardRecommendation
        case DisplayType.accountsWithOutstandingRed.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .accountsWithOutstandingRed
        case DisplayType.accountsWithUtilizationRed.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .accountsWithUtilizationRed
        case DisplayType.accountsWithGreen.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .accountsWithGreen
        case DisplayType.accountsWithPayoffOrange.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .accountsWithPayoffOrange
        case DisplayType.verticalQuestions.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .verticalQuestions
        case DisplayType.horizontalQuestions.rawValue:
            ChatDataController.sharedInstance.currentDisplayType = .horizontalQuestions
        default:
            break
        }
    }

    public static func loadJSONFromBundle(name:String,bundle:Bundle)->[String:Any]?{
        if let path = bundle.path(forResource: name, ofType: "json"){
            let url = URL(fileURLWithPath: path)
            do{
                let data = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
                do{
                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    return dict as? [String:Any]
                }catch{
                    
                }
            }catch{
                
            }
        }
        return nil
    }
    
    public static func isEligibleToPlayVideo(cell: MessageCollectionViewCell) -> Bool {
        var isVideoEligible = false
        for view in cell.subviews {
            for subview in view.subviews {
                if let containerView = subview as? MessageContainerView {
                    for containerSubview in containerView.subviews {
                        if let playButton = containerSubview as? PlayButtonView, playButton.isHidden == false {
                            isVideoEligible = true
                        }
                    }
                }
            }
        }
        return isVideoEligible
    }
    
}

extension NSDate {

    func dateToTimeFormat(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let dateString = formatter.string(from: self as Date)
        let postMessageDate = formatter.date(from: dateString)
        formatter.dateFormat = format
        return formatter.string(from: postMessageDate!)
        /*
       Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
       09/12/2018                        --> MM/dd/yyyy
       09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
       Sep 12, 2:11 PM                   --> MMM d, h:mm a
       September 2018                    --> MMMM yyyy
       Sep 12, 2018                      --> MMM d, yyyy
       Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
       2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
       12.09.18                          --> dd.MM.yy
       10:41:02.112                      --> HH:mm:ss.SSS
       */
    }
}
extension Date {
    
    func dateFormat(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let dateString = formatter.string(from: self as Date)
        let postMessageDate = formatter.date(from: dateString)
        formatter.dateFormat = format
        return formatter.string(from: postMessageDate!)
        /*
         Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
         09/12/2018                        --> MM/dd/yyyy
         09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
         Sep 12, 2:11 PM                   --> MMM d, h:mm a
         September 2018                    --> MMMM yyyy
         Sep 12, 2018                      --> MMM d, yyyy
         Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
         2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
         12.09.18                          --> dd.MM.yy
         10:41:02.112                      --> HH:mm:ss.SSS
         */
    }
}



