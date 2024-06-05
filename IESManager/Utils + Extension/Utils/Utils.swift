//
//  Utils.swift
//  VeeaHub Manager
//
//  Created by Al on 09/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit

infix operator <-

/* If `rhs` can be casted to
 * the type of `lhs`, assign
 * the unwrapped value in `rhs`
 * to `lhs`. Essentially,
 * shorthand for assignment
 * using `if let`.
 */
func <- <T, U>(lhs: inout T, rhs: U) {
    
    if let val = rhs as? T {
        
        lhs = val
        
    }
    
}

func <- <T, U>(lhs: inout T!, rhs: U?) {
    
    if let val = rhs as? T {
        
        lhs = val
        
    }
}

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
#if targetEnvironment(simulator)
        isSim = true
#endif
        
        return isSim
    }()
}

class Utils {
    class func animatedRefresh(tableView: UITableView) {
        tableView.beginUpdates() // neat trick to force animation of table view cell heights
        tableView.endUpdates()
    }
    
    class func blobsFor(string: String) -> String {
        var blobs = ""
        for _ in 0..<string.lengthOfBytes(using: .utf8) {
            blobs = blobs + "•"
        }
        
        return blobs
    }
    
    class func generateRandomSSID() -> String {
        let chars : NSString = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let charCount = UInt32(chars.length)
        
        var ssid = "vm"
        for _ in 0 ..< 6 {
            let r = Int(arc4random_uniform(charCount))
            var c = chars.character(at: r)
            ssid += NSString(characters: &c, length: 1) as String
        }
        
        return ssid
    }

    class func globalTint() -> UIColor {
        //return UIColor(red:0.42, green:0.33, blue:0.94, alpha:1.0) // Virtuosys Color
        
        return UIColor(named: "Veea Background") ?? .blue
    }
    
    class func localTimeStringFromUTC(string: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: string) {
            formatter.timeZone = TimeZone.current
            return formatter.string(from: date)
        }
        
        return "Unknown".localized()
    }
    
    class func showInputAlert(from: UITableViewController, indexPath: IndexPath, title: String, message: String, initialValue: String?, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = initialValue
            textField.clearButtonMode = .whileEditing
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let textField = alert.textFields?[0] {
                completion(textField.text!)
                
                let cell = from.tableView.cellForRow(at: indexPath) // workaround for empty string bug (textField isn't updated if initial value is "" or nil)
                cell?.setNeedsLayout()
            }
        }))
        
        from.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Utils.globalTint()
    }
    
    class func showInputAlert(from: UIViewController, title: String, message: String, initialValue: String?, okButtonText: String?, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = initialValue
            textField.accessibilityIdentifier = "textField"
            textField.clearButtonMode = .whileEditing
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        var ok = "OK"
        if let okButtonText = okButtonText {
            ok = okButtonText
        }
        alert.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in
            if let textField = alert.textFields?[0] {
                completion(textField.text!)
            }
        }))
        
        from.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Utils.globalTint()
    }
    
    class func utcStringFrom(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    class func intArrayToString(arr: [Int]) -> String {
        var str = String()
        for i in arr {
            str.append("\(i),")
        }
        
        return String(str.dropLast())
    }
    
    static func getByteArray(_ data: NSData) -> [UInt8] {
        let count = data.length / MemoryLayout<UInt8>.size
        var array = [UInt8](repeating: 0, count: count)
        data.getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        
        return array
    }
    
    static func hexStringFromBytes(_ bytes: [UInt8]) -> String {
        return bytes.map { String(format: "%02hhx", $0) }.joined()
    }
    
    static func loadFromPlist(named plistName: String) -> [String] {
        for framework in Bundle.allFrameworks {
            if let id = framework.bundleIdentifier {
                if id.contains("ies.library") {
                    if let url = framework.url(forResource: plistName, withExtension: "plist") {
                        return NSArray(contentsOf: url) as! [String]
                    }
                }
            }
        }
        
        return []
    }
    
    static func stringFromByteArray(_ bytes: [UInt8]) -> String? {
        return String(bytes: bytes, encoding: String.Encoding.utf8)
    }
    
    static func stringToByteArray(_ string: String) -> [UInt8] {
        return Array(string.utf8) as [UInt8]
    }
    
    static func safeName(_ name: String) -> String {
        return name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    }
}
