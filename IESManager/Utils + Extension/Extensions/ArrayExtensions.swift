//
//  ArrayExtensions.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 27/06/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Array {
    /// Gets the object at a given index. If out of range, nil is returned. Instead of a crash
    /// - Parameter index: the index
    /// - Returns: the element or nil
    func at(index: Int) -> Element? {
        if index < 0 || index > self.count - 1 {
            return nil
        }
        return self[index]
    }
}


extension String {
    func localized(_ comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}

protocol Copying {
    init(original: Self)
}

//Concrete class extension
extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

//Array extension for elements conforms the Copying protocol
// deep copy
extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}
