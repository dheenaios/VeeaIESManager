//
//  OnboardingBaseViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit
import Network


/// Base View controller for logging and enrolling a new VeeaHub
class OnboardingBaseViewController: HomeUserBaseViewController {
    
    var vSpinner : UIView?
}

// MARK: - Sending
extension OnboardingBaseViewController {
    func sendAndShowComplete() {
        // Do the send
        showSpinner()
        navController.newEnrollment.sendEnrollmentData { result in
            self.removeSpinner()
            if result.0 { // Success
                self.navController.pushViewController(EnrollmentCompleteViewController.new(), animated: true)
            }
            else {
                showAlert(with: "Error",
                          message: result.1 ?? "Error getting configuration details.\nPlease wait a moment and try again.".localized(),
                          callback: nil)
            }
        }
    }
}

// MARK: - Spinner
extension OnboardingBaseViewController {
    func showSpinner() {
        let spinnerView = UIView.init(frame: view.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.view.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}
