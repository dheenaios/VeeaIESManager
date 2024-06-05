//
//  InlineHelpView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 18/10/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit

class InlineHelpView: LoadedXibView {
    @IBOutlet private var rootView: UIView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var learnMoreLabel: UILabel!
    
    private var observer: (() -> Void)?
    
    @IBAction func learnMoreTapped(_ sender: Any) {
        if learnMoreLabel.isHidden { return }
        guard let o = observer else { return }
        o()
    }
    
    func setText(labelText: String) {
        textLabel.text = labelText
        learnMoreLabel.text = "Learn More".localized()
    }

    func hideLearnMore() {
        learnMoreLabel.isHidden = true
    }

    func observerTaps(observer: @escaping (() -> Void)) {
        self.observer = observer
    }
    
    // MARK: - Init
    override func loaded() {
        textLabel.text = ""
        learnMoreLabel.text = ""
    }
}
