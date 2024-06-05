//
//  ReleaseLogViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 15/08/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit

class ReleaseLogViewController: HelpViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the doc
        loadText(textString: loadMarkDownStringFromFile(path: "Help Documentation/ReleaseLog"))
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let shareText = loadMarkDownStringFromFile(path: "Help Documentation/ReleaseLog")
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}
