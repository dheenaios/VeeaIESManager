//
//  LoadFirewallViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 02/10/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit


class GetFirewallDetailsViewController: BaseConfigViewController {

    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var previewField: UITextView!
    
    @IBOutlet weak var getRulesButton: UIButton!
    @IBOutlet weak var saveShareButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewField.text = ""
        
        if getConnectionType() == nil {
            disableButtons(disable: true)
            previewField.text = "Not connected to a hub. Connect, then come back.".localized()
        }
        
        disableButtons(disable: false)
    }
    
    private func disableButtons(disable: Bool) {
        getRulesButton.isEnabled = !disable
        saveShareButton.isEnabled = !disable
    }

    @IBAction func getRulesTapped(_ sender: Any) {
        guard let connection = veeaHubConnection else {
            return
        }
        
        ApiFactory.api.getAllFirewallRules(connection: connection) { (rules, error) in
            if let error = error {
                self.previewField.text = "Error: ".localized() + error.errorDescription()
                return
            }
            
            self.populateRules(rules: rules)
        }
    }
    
    private func populateRules(rules: [FirewallRule]?) {
        var str = "Connection Type: \(getConnectionType() ?? "No connection")\n"
        str.append("Description: \(descriptionField.text ?? "None")\n\n")
        
        guard let rules = rules else {
            str.append("No rules returned")
            previewField.text = str
            return
        }
        
        if rules.isEmpty {
            str.append("Rules array is empty")
        }
        
        for rule in rules {
            guard let json = rule.originalJson else {
                return
            }
            
            let jsonStr = json.description
            
            str.append(jsonStr)
            str.append("\n")
        }
        
        previewField.text = str
    }
    
    @IBAction func saveAndShareTapped(_ sender: Any) {
        shareFile()
    }
    
    func shareFile() {
        
        var connectionName = "MAS Connection"
        
        if let connection = HubDataModel.shared.connectedVeeaHub as? VeeaHubConnection {
            connectionName = connection.hubDisplayName
        }
        if let connection = HubDataModel.shared.connectedVeeaHub as? MasConnection {
            connectionName = "MAS Connection to Hub ID \(connection.nodeId)"
        }
        
        let df = DateFormatter.iso8601Full
        let fileName = "\(df.string(from: Date())) - Snapshot for \(connectionName).json"
        
        var snapshot = [String : Any]()
        snapshot["Firewall"] = previewField.text ?? "No info"
        
        guard let url = FileHelper.saveDictionary(dict: snapshot, named: fileName) else {
            previewField.text = "Error saving the snapshot"
            
            return
        }

        let activity = UIActivityViewController.init(activityItems: [url], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activity, animated: true, completion: nil)
    }
    
    private func getConnectionType() -> String? {
        let connection = veeaHubConnection
        
        if connection is MasConnection {
            return "Connected via MAS"
        }
        else if connection is VeeaHubConnection {
            return "Connected directly to Hub"
        }
        
        return nil
    }

}
