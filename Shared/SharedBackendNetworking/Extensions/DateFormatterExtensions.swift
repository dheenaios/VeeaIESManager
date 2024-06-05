//
//  DateFormatterExtensions.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 16/06/2022.
//

import Foundation

public extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let shortDateTimeWithSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy - HH:mm:ss.SSS"
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()

    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
