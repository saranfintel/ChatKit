//
//  Date+Helper.swift
//  BanfieldAskSpot
//
//  Created by Sarankumar on 31/08/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation
let dateFormatter = DateFormatter()
extension Date {
    
    func epochTimeRoundedTo13Digits() -> Double {
        return round(self.timeIntervalSince1970 * 1000)
    }
    func epochTimeRoundedTo9Digits() -> TimeInterval {
        var timeIntervalSince1970 = self.timeIntervalSince1970
        timeIntervalSince1970 = Double(round(round(1000*timeIntervalSince1970)/1000))
        return timeIntervalSince1970
    }
    
    //MARK:- Date Conversion
    func dateConversion() -> String {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateFormat = dateFormatter
        var dateString : String = ""
        // Today Date
        let todayDate = Date()
        let fromDBcalendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.year, .month, .day]
        let fromDBcomponents = (fromDBcalendar as NSCalendar).components(unitFlags, from: self)
        let dateCalendar = Calendar.current
        let dateComponents = (dateCalendar as NSCalendar).components(unitFlags  , from: self, to: todayDate, options: [])
        if dateComponents.year! > 0 || dateComponents.month! > 0 || dateComponents.day! > 6 {
            dateString = dateFormat.string(from: self)
        } else {
            switch Int(dateComponents.day!)
            {
            case 0:
                let todayCalendar = Calendar.current
                let todaycomponents = (todayCalendar as NSCalendar).components(unitFlags, from: todayDate)
                if todaycomponents.year == fromDBcomponents.year && todaycomponents.month == fromDBcomponents.month && todaycomponents.day == fromDBcomponents.day {
                    dateFormatter.dateFormat = "hh:mm a"
                    dateString = dateFormat.string(from: self)
                }
                else{
                    dateString = "Yesterday"
                }
            case 1...6:
                dateFormatter.dateFormat = "EEEE"
                dateString = dateFormat.string(from: self)
                
            default:
                dateString = dateFormat.string(from: self)
                
            }
        }
        return dateString
    }
    
    // This methos set the time info to zero and returns the date with time zone date
    func dateWithoutTime() -> Date? {
        let unitFlags: NSCalendar.Unit = [.day, .month, .year]
        var components = (Calendar.current as NSCalendar).components(unitFlags, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }
    
    func addSecondsToCurrentDate(seconds: NSInteger) -> NSDate? {
        let unitFlags: NSCalendar.Unit = [.day, .month, .year, .hour, .minute, .second]
        var components = (Calendar.current as NSCalendar).components(unitFlags, from: self)
        components.second = components.second! + seconds
        return Calendar.current.date(from: components) as NSDate?
    }
    
    func addMinuteToCurrentDate(minute: Int) -> Date? {
        let unitFlags: NSCalendar.Unit = [.day, .month, .year, .hour, .minute, .second]
        var components = (Calendar.current as NSCalendar).components(unitFlags, from: self)
        components.minute = components.minute! + minute
        return Calendar.current.date(from: components)
    }
    
    func addDayToCurrentDate(day: Int) -> Date? {
        let unitFlags: NSCalendar.Unit = [.day, .month, .year, .hour, .minute, .second]
        var components = (Calendar.current as NSCalendar).components(unitFlags, from: self)
        components.day = components.day! + day
        return Calendar.current.date(from: components)
    }
    
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    func toMonthAndYear() -> String {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.dateFormat = "MMM dd, EEEE"
        return  dateFormatter.string(from: self)
    }
    
    func toHours() -> String {
        let timeFormatter = Foundation.DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        return timeFormatter.string(from: self)
    }
    
    func currentDateConversion() -> String {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateFormat = dateFormatter
        var dateString : String = ""
        // Today Date
        let todayDate = Date()
        let fromDBcalendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.year, .month, .day]
        let fromDBcomponents = (fromDBcalendar as NSCalendar).components(unitFlags, from: self)
        let dateCalendar = Calendar.current
        let dateComponents = (dateCalendar as NSCalendar).components(unitFlags  , from: self, to: todayDate, options: [])
        if dateComponents.year! > 0 || dateComponents.month! > 0 || dateComponents.day! > 6 {
            dateString = dateFormat.string(from: self)
        }
        else
        {
            switch Int(dateComponents.day!)
            {
            case 0:
                let todayCalendar = Calendar.current
                let todaycomponents = (todayCalendar as NSCalendar).components(unitFlags, from: todayDate)
                
                if todaycomponents.year == fromDBcomponents.year && todaycomponents.month == fromDBcomponents.month && todaycomponents.day == fromDBcomponents.day {
                    dateString = "Today"
                }
                else{
                    dateString = dateFormat.string(from: self)
                }
            case 1...6:
                dateString = dateFormat.string(from: self)
                
            default:
                dateString = dateFormat.string(from: self)
                
            }
        }
        return dateString
    }
    
    func selectedDateConversion() -> String {
        let date = String(format: "%.2f",round(self.timeIntervalSince1970 * 1000))
        let shiftedStartIndex = date.index(date.startIndex, offsetBy: (date).count - 3)
        let timeIntervalSince1970 =  date.substring(to: shiftedStartIndex)
        return String(timeIntervalSince1970)
    }

}

extension TimeInterval {
    func toString() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0 // fractions removed
        return formatter.string(from: NSNumber(value: self))!
    }
}
extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        if #available(iOS 11.0, *) {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        } else {
            // Fallback on earlier versions
        }
        return formatter
    }()
}
