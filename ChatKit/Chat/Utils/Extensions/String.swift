//
//  StringExtension.swift
//  SlideMenuControllerSwift
//

import Foundation
import UIKit

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(_ from: Int) -> String {
        return self.substring(from: self.index(self.startIndex, offsetBy: from))
    }
    
    var length: Int {
        return self.count
    }
    
}



extension String {
        
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func trimTrailingWhitespace() -> String {
        if let trailingWs = self.range(of: "\\s+$", options: .regularExpression) {
            return self.replacingCharacters(in: trailingWs, with: "")
        } else {
            return self
        }
    }
    
    func addBRtag() -> String {
        return self.replacingOccurrences(of: "<br>", with: "<br><br>")
    }
    
    func fullrange() -> NSRange {
        return NSMakeRange(0, self.length + self.countEmojiCharacter())
    }
    
    func countEmojiCharacter() -> Int {
        
        func isEmoji(s:NSString) -> Bool {
            
            let high:Int = Int(s.character(at: 0))
            if 0xD800 <= high && high <= 0xDBFF {
                let low:Int = Int(s.character(at: 1))
                let codepoint: Int = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000
                return (0x1D000 <= codepoint && codepoint <= 0x1F9FF)
            }
            else {
                return (0x2100 <= high && high <= 0x27BF)
            }
        }
        
        let nsString = self as NSString
        var length = 0
        
        nsString.enumerateSubstrings(in: NSMakeRange(0, nsString.length), options: NSString.EnumerationOptions.byComposedCharacterSequences) { (subString, substringRange, enclosingRange, stop) -> Void in
            let string = (subString ?? "") as NSString
            if isEmoji(s: string) {
                length += 1
            }
        }
        
        return length
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}


extension String {
    func calculateHeight() -> CGFloat {
        let constraintRect = CGSize(width: CGFloat(UIDevice().chatViewMaxWidth - chatWidthSpaces), height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0)], context: nil)
        return ceil(boundingBox.height)
    }
}

/*
 HTML  String to AttributedString
 */
extension String {
    
    var htmlToAttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8),
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            //print("error: ", error)
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

public extension UIDevice {
    //MARK:- Chat view size
    var chatViewMaxWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.75
    }
    
}
