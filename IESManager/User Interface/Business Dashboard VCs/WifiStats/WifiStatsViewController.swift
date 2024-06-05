//
//  WifiStatsViewController.swift
//  VeeaHub Manager
//
//  Created by Al on 20/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit


class WifiStatsViewController: UIViewController, HubInteractionFlowControllerProtocol {
    var flowController: HubInteractionFlowController?
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var vmeshIcon: UIImageView!
    @IBOutlet weak var vmeshSignal: UILabel!
    @IBOutlet weak var vmeshQuality: UILabel!
    @IBOutlet weak var backhaulIcon: UIImageView!
    @IBOutlet weak var backhaulSignal: UILabel!
    @IBOutlet weak var backhaulQuality: UILabel!

    var vm = WifiStatsViewModel()
    
    var stats: WifiStats?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.refresh(self.refreshButton as Any)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func refresh(_ sender: Any) {
        
        vm.refresh { [weak self]  (wifiStats, error) in
            if let stats = wifiStats {
                self?.stats = stats
                
                self?.vmeshIcon.image = UIImage(named: "wifi_\(stats.vmesh_signal_level)_bars")
                self?.vmeshSignal.text = "\(stats.vmesh_signal)"
                self?.vmeshQuality.text = "\(stats.vmesh_quality)"
                
                self?.backhaulIcon.image = UIImage(named: "wifi_\(stats.backhaul_signal_level)_bars")
                self?.backhaulSignal.text = "\(stats.backhaul_signal)"
                self?.backhaulQuality.text = "\(stats.backhaul_quality)"
                
            } else if let error = error {
                NSLog("error obtaining stats: \(error)")
            }
        }
    }
}
