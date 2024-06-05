//
//  PasswordCellTableViewCell.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 11/09/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit

class PasswordCellTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    private var showPassword = true // True is the in
    
    public var password: String? {
        didSet {
            showPassword = true // This will be toggled to false
            togglePasswordVisibility(self)
        }
    }
    
    
    @IBAction func togglePasswordVisibility(_ sender: Any) {
        let pass = password ?? ""
        
        showPassword = !showPassword
        let blobs = Utils.blobsFor(string: pass)
        let clearText = pass
        
        valueLabel.text = showPassword == true ? clearText : blobs

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
