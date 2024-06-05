//
//  DateExtensions.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 11/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

extension Date {
    
    public static func dateFromEpoch(epoch: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(epoch))
    }
    
    public static func stringFromEpoch(epoch: Int) -> String {
        let d = Date(timeIntervalSince1970: TimeInterval(epoch))
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        let dateString = dateFormatter.string(from: d)
        
        return dateString
    }
    
    public func inLast(seconds: Int) -> Bool {
        let now = Date()
        let interval = Calendar.current.dateComponents([.second], from: self, to: now).second ?? 0
        
        return interval < seconds
    }
    
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
