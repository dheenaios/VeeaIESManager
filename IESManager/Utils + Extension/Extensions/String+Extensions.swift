//
//  String+Extensions.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/23/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /** True if the string is a valid e-mail. */
    public var isValidEmail: Bool {
        get {
            let regex = try? NSRegularExpression(pattern: "^[[:alnum:]._%+-]+@[[:alnum:].-]+\\.[A-Z]+$", options: .caseInsensitive)
            return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
        }
    }
    
    /// True if the string is a valid phone number.
    public var isValidPhoneNumber: Bool {
        get {
            let regex = try? NSRegularExpression(pattern: "^[1-9][0-9]*$", options: .caseInsensitive)
            return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
        }
    }
    
    var isNumeric: Bool {
      return !(self.isEmpty) && self.allSatisfy { $0.isNumber }
    }
    
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
    
    func setTwoDifferentFontsForLabel(string1:String, string2:String, str1TextColor:UIColor, str2TextColor:UIColor) -> NSAttributedString {
        let attrs1 = [NSAttributedString.Key.font : FontManager.infoText, NSAttributedString.Key.foregroundColor : str1TextColor]
        let attrs2 = [NSAttributedString.Key.font : FontManager.infoText, NSAttributedString.Key.foregroundColor : str2TextColor]
        let attributedString1 = NSMutableAttributedString(string:string1, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:string2, attributes:attrs2)
        attributedString1.append(attributedString2)
        return attributedString1
    }
}

extension String {
    func split(from: Int, to: Int) -> String {
        if from > to {
            return ""
        }
        let start = index(startIndex, offsetBy: from)
        let end = index(startIndex, offsetBy: to)
        return String(self[start...end])
    }
}

extension String {
    
    /// Inner comparison utility to handle same versions with different length. (Ex: "1.0.0" & "1.0")
    private func compare(toVersion targetVersion: String) -> ComparisonResult {
        
        let versionDelimiter = "."
        var result: ComparisonResult = .orderedSame
        var versionComponents = components(separatedBy: versionDelimiter)
        var targetComponents = targetVersion.components(separatedBy: versionDelimiter)
        let spareCount = versionComponents.count - targetComponents.count
        
        if spareCount == 0 {
            result = compare(targetVersion, options: .numeric)
        } else {
            let spareZeros = repeatElement("0", count: abs(spareCount))
            if spareCount > 0 {
                targetComponents.append(contentsOf: spareZeros)
            } else {
                versionComponents.append(contentsOf: spareZeros)
            }
            result = versionComponents.joined(separator: versionDelimiter)
                .compare(targetComponents.joined(separator: versionDelimiter), options: .numeric)
        }
        return result
    }
    
    public func isVersion(equalTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedSame }
    public func isVersion(greaterThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedDescending }
    public func isVersion(greaterThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedAscending }
    public func isVersion(lessThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedAscending }
    public func isVersion(lessThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedDescending }
}
