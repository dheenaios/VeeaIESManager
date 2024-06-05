//
//  IPValueView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 12/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

class IPValueView: TitledTextField {
    
    override func textFieldDidChange(_ sender: UITextField) {
        guard let str = sender.text else {
            return
        }
        
        sender.textColor = AddressAndPortValidation.isIPValid(string: str) ? UIColor.black : UIColor.red
    }
    
    override func initialPopulate() {
        super.initialPopulate()
        
        setKeyboardType(type: .decimalPad)
    }

}
