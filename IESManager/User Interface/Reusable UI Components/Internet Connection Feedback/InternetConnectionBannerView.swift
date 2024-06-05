//
//  InternetConnectionBanner.swift
//  IESManager
//
//  Created by Richard Stockdale on 19/05/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

class InternetConnectionBannerView: LoadedXibView {

    @IBOutlet var rootView: UIView!
    @IBOutlet weak var offlineImage: UIImageView!
    @IBOutlet weak var noConnectionLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!

    @IBOutlet weak var dismissTapped: UIButton!

    override func setTheme() {
        super.setTheme()
        noConnectionLabel.font = FontManager.light(size: 17)
    }

    @IBAction func didTapDismiss(_ sender: Any) {
        dismissBanner()
    }

    private func dismissBanner() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction) {
                self.alpha = 0.0
            } completion: { complete in
                self.removeFromSuperview()
            }
        }
    }
}
