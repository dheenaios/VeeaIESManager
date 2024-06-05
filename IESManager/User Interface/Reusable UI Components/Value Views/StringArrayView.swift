//
//  StringArrayView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 10/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

class StringArrayView: UIView {
    @IBOutlet var xibView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var clearButton: UIButton!
    
    func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    @IBInspectable var title: String? {
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

    // MARK: - INIT
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("StringArrayView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("StringArrayView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
