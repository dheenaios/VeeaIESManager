//
//  TimeConfigViewController.swift
//  VeeaHub Manager
//
//  Created by Al on 09/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit


// MARKED FOR DELETION ON 5 August 2020.
// Remove if no objections

class TimeConfigViewController: BaseConfigTableViewController, HubInteractionFlowControllerProtocol {
    var flowController: HubInteractionFlowController?
    
    let vm = TimeConfigViewModel()
    
    @IBOutlet weak var iesTime: UILabel!
    @IBOutlet weak var restartTime: UILabel!
    @IBOutlet weak var restartReason: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.update()
        self.refreshIesTime(self.refreshButton as Any)
    }
    
    private func update() {
        DispatchQueue.main.async {
            self.iesTime.text = self.vm.nodeTime
            self.restartTime.text = self.vm.restartTime  // restart time is NOT returned as UTC!
            self.restartReason.text = self.vm.restartReason
        }
        
        tableView.reloadData()
    }
    
    override func applyConfig() {        
        dismissCard()
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 86
        }
        
        return 44
    }
    
    @IBAction func refreshIesTime(_ sender: Any) {
        vm.refreshTime { (message, error) in
            if error != nil {
                return
            }
            
            self.update()
        }
    }
}
