//
//  JsonDiffer.swift
//  JsonDiff
//
//  Created by richardstockdale on 28/04/2021.
//

import Foundation

class JsonDiffer {

    // Things that should not be
    enum JsonDiffingErrors: Error {
        case conflictingTypes
        case differentKeys
        case unexpectedType
        case unknownError
    }
    
    static func diffJson(original: JSON,
                         target: JSON) throws -> JSON {
        var returnJson = JSON()

        // Remove DB management keys
        var o = original
        o.removeValue(forKey: "_rev")
        o.removeValue(forKey: "_id")

        // The Hub API does not let us add keys so they should be exactly the same
        if o.keys != target.keys {
            throw JsonDiffingErrors.differentKeys
        }
        
        // Go through the keys in  the original. For each get the same in the target
        // Check if there is a difference
        // If there is a difference then we need to add that to our return json
        for key in o.keys {
            if let originalValue = o[key],
               let targetValue = target[key] {

                do {
                    let diff = try difference(key: key,
                                              originalValue: originalValue,
                                              targetValue: targetValue)
                    if diff {
                        returnJson[key] = targetValue
                    }
                }
                catch {
                    throw error
                }
            }
            else {
                throw JsonDiffingErrors.unknownError
            }
        }
        
        return returnJson
    }

    // Work out the equitable kind. Number, String, Object, Array
    private static func difference(key: String,
                                   originalValue: Any,
                                   targetValue: Any) throws -> Bool {

        do {
            return try anyDiffs(key: key,
                                originalValue: originalValue,
                                targetValue: targetValue)
        }
        catch {
            throw error
        }
    }
    
    private static func anyDiffs(key: String,
                                 originalValue: Any,
                                 targetValue: Any) throws -> Bool {

        do {
            if type(of: originalValue) != type(of: targetValue) {
                if !canBeCast(originalValue: originalValue, targetValue: targetValue) {
                    throw JsonDiffingErrors.conflictingTypes
                }
            }

            if originalValue is NSNull && targetValue is NSNull {
                return false
            }
            
            if key == "lease_time" && originalValue is String {
                return false
            }

            if let ov = originalValue as? NSNumber {
                let tv = targetValue as! NSNumber
                return hasNumberDiffs(key: key,
                                      originalValue: ov,
                                      targetValue: tv)
            }
            if let ov = originalValue as? String {
                let tv = targetValue as! String
                return hasStringDiffs(key: key,
                                      originalValue: ov,
                                      targetValue: tv)
            }
            if let ov = originalValue as? [Any] {
                let tv = targetValue as! [Any]
                return try hasArrayDiffs(key: key,
                                     originalValue: ov,
                                     targetValue: tv)
            }
            if let ov = originalValue as? [String : Any] {
                let tv = targetValue as! [String : Any]
                return try hasDictDiffs(key: key,
                                    originalDict: ov,
                                    targetDict: tv)
            }
        }
        catch {
            throw error
        }

        throw JsonDiffingErrors.unexpectedType
    }

    // Some values can come is as NSCF versions of the targets. If they can be cast
    // they are practically the same, even if not actually the same.
    private static func canBeCast(originalValue: Any, targetValue: Any) -> Bool {
        if let ov = originalValue as? NSNumber {
            if ov.isBoolean && targetValue is Bool {
                return true
            }
        }

        // Swift dictionaries may appear as NSDictionaries. The above will not catch that
        if !(originalValue is [String : Any] && targetValue is [String : Any]) {
            return true
        }


        return false
    }
    
    private static func hasNumberDiffs(key: String,
                                       originalValue: NSNumber,
                                       targetValue: NSNumber) -> Bool {
        let equal = originalValue.isEqual(to: targetValue)
        return !equal
    }
    
    private static func hasStringDiffs(key: String,
                                       originalValue: String,
                                       targetValue: String) -> Bool {
        let equal = originalValue == targetValue
        return !equal
    }
    
    private static func hasArrayDiffs(key: String,
                                      originalValue: [Any],
                                      targetValue: [Any]) throws -> Bool {
        
        if originalValue.count != targetValue.count {
            return true
        }
        
        for (index, anyItem) in originalValue.enumerated() {
            let targetAny = targetValue[index]

            do {
                let diff = try anyDiffs(key: key, originalValue: anyItem, targetValue: targetAny)
                if diff {
                    return true
                }
            }
            catch {
                throw error
            }
        }
        
        return false
    }
    
    private static func hasDictDiffs(key: String,
                                     originalDict: [String : Any],
                                     targetDict: [String : Any]) throws -> Bool {
        
        for key in originalDict.keys {
            if let originalValue = originalDict[key],
               let targetValue = targetDict[key] {
                
                if let ov = originalValue as? NSNumber {
                    let tv = targetValue as! NSNumber
                    let diff = hasNumberDiffs(key: key,
                                              originalValue: ov,
                                              targetValue: tv)
                    if diff {
                        return diff
                    }
                }
                if let ov = originalValue as? String {
                    let tv = targetValue as! String
                    let diff = hasStringDiffs(key: key,
                                              originalValue: ov,
                                              targetValue: tv)
                    if diff {
                        return diff
                    }
                }
                if let ov = originalValue as? [Any] {
                    let tv = targetValue as! [Any]

                    do {
                        let diff = try hasArrayDiffs(key: key,
                                                     originalValue: ov,
                                                     targetValue: tv)
                        if diff { return diff }
                    }
                    catch {
                        throw error
                    }
                }
                if let ov = originalValue as? [String : Any] {
                    let tv = targetValue as! [String : Any]

                    do {
                        let diff = try hasDictDiffs(key: key,
                                                originalDict: ov,
                                                targetDict: tv)
                        if diff {
                            return diff
                        }
                    }
                    catch {
                        throw error
                    }
                }
            }
        }
        
        return false
    }

    // MARK: - Type checking
    private static func areTheySiblings(class1: Any, class2: Any) -> Bool {
        return object_getClassName(class1) == object_getClassName(class2)
    }
}
