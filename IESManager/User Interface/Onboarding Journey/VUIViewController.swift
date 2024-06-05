//
//  VUIViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/4/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class VUIViewController: UIViewController {
    var colorManager = InterfaceManager.shared.cm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBackground
        self.navigationController?.view.backgroundColor = .vBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VKReachabilityManager.monitorNetworkChanges(delegate: self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        // Update the navbar globally and locally
        updateNavBarWithDefaultColors()
        // To be implemented in the subclass
    }

    func reachabilityUpdated(status: VKReachabilityManagerStatus) {
        if status == .connected {
            self.updatePrompt(with: nil)
        } else if status == .disconnected {
            self.updatePrompt(with: "No Connection".localized())
        }
    }
    
    func updatePrompt(with text: String?) {
        UIView.animate(withDuration: 0.4) {
            self.navigationItem.prompt = text
        }
    }
}

extension VUIViewController: VKReachabilityManagerDelegate {
    
    func reachabilityStatusChanged(status: VKReachabilityManagerStatus) {
        self.reachabilityUpdated(status: status)
    }
}

var vSpinner : UIView?

extension VUIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

extension VUIViewController {
    func unEnrollHub(node: VHMeshNode) {
        self.showSpinner(onView: self.view)
        HubRemover.remove(node: node) { (success, errorString) in
            self.removeSpinner()
            
            if success {
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
    }
}
