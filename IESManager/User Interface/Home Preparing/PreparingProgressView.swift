//
//  PreparingProgressView.swift
//  IESManager
//
//  Created by Richard Stockdale on 11/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

class PreparingProgressView: LoadedXibView {
    @IBOutlet weak var preparingLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var progressView: HorizontalProgressBar!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    private var lastStatus: EnrollStatusViewModel?
    
    override func loaded() {
        progressView.progress = 0.0
    }
    
    func update(status: EnrollStatusViewModel?) {
        guard let status = status else {
            setInitialState()
            return
        }

        
        self.lastStatus = status
        
        if status.didFail {
            progressView.color = InterfaceManager.shared.cm.statusRed.colorForAppearance
            setErrorState()
            return
        }
        
        if status.percentage == 100 {
            setCompleteState()
            return
        }
        
        setUpdatingState()
    }
    
    private func setInitialState() {
        preparingLabel.text = "Getting enrollment state".localized()
        progressView.progress = 0.0
        showImage(image: nil)
    }
    
    private func setErrorState() {
        preparingLabel.text = "Installation has Failed".localized()
        infoLabel.text = "Device is not ready to use.".localized()
        progressView.progress = 1.0
        showImage(image: UIImage(named: "state-circle + cross"))
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = InterfaceManager.shared.cm.text1.colorForAppearance
    }
    
    private func setUpdatingState() {
        preparingLabel.text = "Preparing".localized() + " (\(Int(lastStatus?.percentage ?? 0))%)"
        progressView.progress = lastStatus!.percentage / 100
        //infoLabel.text = "Approx. Time Remaining: " + "\(Int(lastStatus!.approxTimeRemaining)) " + "minutes"
        infoLabel.text = "\(lastStatus!.nextNonCompleteItem.text)"
        showImage(image: nil)
    }
    
    private func setCompleteState() {
        preparingLabel.text = "Complete".localized()
        infoLabel.text = "Device is ready to use."
        progressView.progress = 1.0
        showImage(image: UIImage(named: "state-circle + tick"))
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "BlackWhite")
    }
    
    
    /// Send in nil to show the spinner.
    /// - Parameter image: Image
    private func showImage(image: UIImage?) {
        guard let image = image else {
            spinner.isHidden = false
            spinner.startAnimating()
            
            return
        }
        
        spinner.isHidden = true
        spinner.stopAnimating()
        
        imageView.image = image
    }
    
    override func setTheme() {
        super.setTheme()
        
        if lastStatus!.didFail {
            progressView.color = InterfaceManager.shared.cm.statusRed.colorForAppearance
            return
        }
        
        progressView.color = InterfaceManager.shared.cm.text1.colorForAppearance
    }
    
}
