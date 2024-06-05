//
//  InlineHelpViewController.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 26/05/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit
import WebKit

class InlineHelpViewController: HelpViewController {
    func removeDone() {
        self.navigationItem.rightBarButtonItems = nil
    }
}
