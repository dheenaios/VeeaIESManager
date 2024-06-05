//
//  UpdateAvailablePillView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 22/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class UpdateAvailablePillView: LoadedXibView {

    @IBOutlet weak var backingView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    private let singleAvailableTitle = "Update Available".localized()
    private let multipleAvailableTitle = "Updates Available".localized()
    private let multipleAvailable = "new updates available".localized()
    private let singleAvailable = "1 new update available".localized()
    
    private var observer: (() -> Void)?
    
    var numberOfUpdates: Int = 0 {
        didSet {
            if numberOfUpdates == 0 { return }
            else if numberOfUpdates == 1 {
                title.text = singleAvailableTitle
                subTitle.text = singleAvailable
                return
            }
            
            title.text = multipleAvailableTitle
            subTitle.text = "\(numberOfUpdates) \(multipleAvailable)"
        }
    }
    
    func observerTaps(observer: @escaping (() -> Void)) {
        self.observer = observer
    }
    
    @IBAction func tapped(_ sender: Any) {
        guard let o = observer else { return }
        o()
    }
    
    override func loaded() {
        backingView.layer.cornerRadius = 15
        backingView.clipsToBounds = true
    }
}
