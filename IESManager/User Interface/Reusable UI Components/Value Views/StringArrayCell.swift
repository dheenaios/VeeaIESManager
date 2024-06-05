//
//  StringArrayCellTableViewCell.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 19/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

class StringArrayCell: BaseValueTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    override func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    var title: String? {
        willSet {
            titleLabel.text = newValue
        }
    }
    
    var userSavedSetting: [String]? {
        willSet {
            guard let strArray = newValue else {
                textView.text = ""
                
                return
            }
            
            textView.text = stringFromStringArray(array: strArray)
        }
    }
    
    var defaultSetting:[String]? {
        willSet {
            guard let strArray = newValue else {
                textView.placeholder = ""
                
                return
            }
            
            textView.placeholder = stringFromStringArray(array: strArray)
        }
    }
    
    var userSetting: String {
        return textView.text
    }
    
    var stringValue: [String] {
        let str = textView.text
        if let strArray = str?.components(separatedBy: "\n") {
            if strArray.count == 1 {
                let val = strArray.first
                if (val?.isEmpty)! {
                    return [String]()
                }
            }
            
            return strArray
        }
        
        return [String]()
    }
    
    // MARK: - UI Interactions
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        textView.text = ""
    }
    
    // MARK: - Helper Methods
    
    private func stringFromStringArray(array: [String]) -> String {
        var str = ""
        
        for entry in array {
            str.append(entry)
            str.append("\n")
        }
        
        return String(str.dropLast())
    }
}
