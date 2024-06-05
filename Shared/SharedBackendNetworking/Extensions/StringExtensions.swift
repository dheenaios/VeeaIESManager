//
//  StringExtensions.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 17/06/2022.
//

import Foundation

extension String {
    public func localized(_ comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
