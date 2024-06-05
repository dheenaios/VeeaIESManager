//
//  PingTestViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 08/08/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking


class PingTestViewController: UIViewController {
    
    @IBOutlet private weak var currentHubIpLabel: UILabel!
    @IBOutlet private weak var ipField: UITextField!
    @IBOutlet private weak var resultsView: UITextView!
    
    var ping: PingProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let connection = HubDataModel.shared.connectedVeeaHub as? VeeaHubConnection else {
            currentHubIpLabel.text = "Connected to MAS. Pinging hubs not supported"
            return
        }
        
        if connection.getHubIp().isEmpty {
            currentHubIpLabel.text = ""
            return
        }
        
        currentHubIpLabel.text = "Current hub IP: \(connection.getHubIp())"
        ipField.text = connection.getHubIp()
    }
    
    @IBAction func pingTapped(_ sender: Any) {
        ipField.resignFirstResponder()
        
        guard !ipField.text!.isEmpty else {
            resultsView.text.append("\nNo IP or host entered")
            return
        }
        
        let ip = ipField.text
        resultsView.text.append("Pinging: \(ip ?? "Nowt")")

        ping = PingFactory.newPing(hostName: ip!)
        ping?.sendPing(stateChange: { result in
            if result == .pingDidFail {
                self.resultsView.text.append("\nPing failed.")
            }
            else if result == .pingDidTimeOut {
                self.resultsView.text.append("\nPing timed out.")
            }
            else if result == .pingDidSucceed {
                self.resultsView.text.append("\nPing succeded.")
            }

            self.resultsView.text.append("\n\n")
        })
    }
}
