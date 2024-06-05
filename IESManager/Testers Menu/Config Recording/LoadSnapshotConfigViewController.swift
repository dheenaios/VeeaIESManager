//
//  LoadSnapshotConfigViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 22/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class LoadSnapshotConfigViewController: UIViewController {
    
    
    @IBOutlet weak var textField: UITextView!
    
    var snapshot: ConfigurationSnapShot?
    
    @IBAction func pasteTapped(_ sender: Any) {
        let content = UIPasteboard.general.string
        textField.text = content
    }

    @IBAction func loadTapped(_ sender: Any) {
        guard let string = textField.text else {
            return
        }
        
        let data = string.data(using: .utf8)!
        do {
            
            let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as! [ String : Any]
            
            snapshot = ConfigurationSnapShot.init(snapShotJson: json)
            
            if snapshot != nil {
                // Post this
                HubDataModel.shared.configurationSnapShotItem = snapshot
                HubDataModel.shared.snapShotInUse = false
                
                navigationController?.popViewController(animated: true)
            }
            else {
                textField.text = "Error creating the data model. JSON have unexpected values."
            }
        } catch let error {
            textField.text = "JSON Parsing error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Example Snapshots
extension LoadSnapshotConfigViewController {
    @IBAction func loadExampleEC10Snapshot(_ sender: Any) {
        guard let example = ExampleSnapshots.ec10Snapshot else {
            textField.text = "Could not load example snapshot"
            return
        }
        textField.text = example
        loadTapped(self)
    }
}
