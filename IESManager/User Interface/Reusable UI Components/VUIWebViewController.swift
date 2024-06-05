//
//  VUIWebViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/2/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SafariServices

class VUIWebViewController: SFSafariViewController {

    convenience init(urlString: String) {
        var url = URL(string: "https://www.veea.com")!
        if let link = URL(string: urlString) {
            url = link
        }
        self.init(url: url)
        
        self.preferredBarTintColor = UIColor.white
        self.preferredControlTintColor = UIColor.vPurple
    }

}
