    //
//  APITestViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 02/07/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit


class APITestViewController: UIViewController {
    
    private let TAG = "APITestViewController"
    
    private let dataBaseNames = ["cellular_data_count",
                                 "mesh_ap_config",
                                 "mesh_lan_config",
                                 "node_ap_config",
                                 "node_capabilities",
                                 "node_config",
                                 "node_control",
                                 "node_info",
                                 "node_metrics",
                                 "node_sdwan",
                                 "node_services",
                                 "node_status",
                                 "node_wan_config",
                                 "public_wifi_info",
                                 "public_wifi_operators",
                                 "public_wifi_settings",
                                 "wifi_metrics",
                                 "mesh_port_config",
                                 "node_port_config",
                                 "node_port_status",
                                 "node_lan_static_ip",
                                 "node_lan_config",
                                 "mesh_vlan_config",
                                 "node_vlan_config",
                                 "node_lan_dhcp",
                                 "node_wan_static_ip"]

    @IBOutlet private weak var tokenValueLabel: UILabel!
    @IBOutlet private weak var dbNameTextField: UITextField!
    @IBOutlet private weak var responseLabel: UILabel!
    @IBOutlet private weak var responseText: UITextView!
    
    @IBOutlet weak var dbPicker: UIPickerView!
    @IBOutlet weak var bottomPickerConstraint: NSLayoutConstraint!
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        if let dbName = dbNameTextField.text {
            makeCall(dbName: dbName)
        }
    }
    
    @IBAction func copyButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string = responseText.text
        Logger.log(tag: TAG, message: "Copied API response: \(responseText.text ?? "None")")
        
        sender.setTitle("Copied", for: .normal)
        
        let delay = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            sender.setTitle("Copy results to clipboard", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setToken()
        connectViaIpOption()
        title = "API Tests"
    }

    private func connectViaIpOption() {
        let ipOverride = UIBarButtonItem(title: "IP Override", style: .done, target: self, action: #selector(ipConnectTapped))
        self.navigationItem.rightBarButtonItem  = ipOverride
    }
    
    @objc private func ipConnectTapped() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "IPConnection", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "IPConnectionViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setToken() {
        guard let authToken = SecureAPIAuthorisation.shared.getCachedToken() else {
            tokenValueLabel.text = "No Cached token. Run at test to populate"
            return
        }
        
        tokenValueLabel.text = authToken
    }
}

// MARK: - Make call
extension APITestViewController {
    
    fileprivate func makeCall(dbName: String) {
        if dbName.isEmpty {
            return
        }
        
        var ies = HubDataModel.shared.connectedVeeaHub
        if ies == nil {
            ies = VeeaHubConnection()
        }
        
        ApiFactory.api.makeCallToDBNamed(connection: ies!, dbName: dbName) { [weak self]  (response) in
            self?.processResponse(response: response)
        }
    }
    
    private func processResponse(response: RequestResponce) {
        var responseString = "Error parsing json"
        
        if let error = response.error {
            responseString = error.localizedDescription
        }
        else {
            if let body = response.responseBody {
                let str = String(data: try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted), encoding: .utf8)!
                responseString = str
            }
            else {
                responseString = "Error parsing the response."
            }
        }
        
        responseText.text = responseString
        self.setToken()
    }
}


// MARK: - Picker
extension APITestViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataBaseNames.count
    }
    
    
    @IBAction func pickButtonTapped(_ sender: Any) {
        showPicker()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let selection = dbPicker.selectedRow(inComponent: 0)
        dbNameTextField.text = dataBaseNames[selection]
        
        hidePicker()
    }
    
    private func showPicker() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.bottomPickerConstraint.constant = 0;
            self.view.layoutIfNeeded()
        }
    }
    
    private func hidePicker() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.bottomPickerConstraint.constant = -270;
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Picker
extension APITestViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataBaseNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dbNameTextField.text = dataBaseNames[row]
    }
}
