//
//  NayaColor.swift
//  Naya
//
//  Created by saran on 08/04/20.
//  Copyright © 2020 fintel Labs. All rights reserved.
//

import UIKit

class ChatColor: UIColor {
    
    // Blue
    class func appTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: ChatSession.colorCode())
    }
    // Light Blue
    class func bubbleTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#63adfd")
    }
    // Black
    class func blackTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#000000")
    }
    // Mid gray
    class func midGrayTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#9B9B9B")
    }
    // Map blue
    class func mapBlueTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#0091FF")
    }
    // Map Green
    class func mapGreenTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#3CAD5F")
    }
    // Map Red
    class func mapRedTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#E02020")
    }
    // OnBoarding
    class func onBoarding1Theme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#9795F0")
    }
    class func onBoarding2Theme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#FF989C")
    }
    class func onBoarding3Theme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#51C9C3")
    }
    class func onBoarding4Theme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#F7CE68")
    }
    class func whiteTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#ffffff")
    }
    // Dark
    class func pageControlTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#929292")
    }
    class func chatDarkTheme() -> UIColor {
        return UIColor.colorFromHex(hexString: "#4A4A4A")
    }

}
