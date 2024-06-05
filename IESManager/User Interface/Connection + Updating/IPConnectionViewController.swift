//
//  IPConnectionViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 03/10/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit


class IPConnectionViewController: UITableViewController {
    
    @IBOutlet private weak var gatewayAddressValue: UILabel!
    @IBOutlet private weak var thisDeviceIPValue: UILabel!
        
    @IBOutlet private weak var connectViaIPSwitch: UISwitch!
    @IBOutlet private weak var hubIPTextField: UITextField!
    @IBOutlet weak var testConnectionKey: UIButton!
    @IBOutlet fileprivate weak var testConnectionValue: UILabel!
    
//    internal static let ipKey = "ipKey"
//    internal static let shouldOverrideGateway = "shouldOverrideGateway"
    
    fileprivate var requestCount = 0
        
    override func viewWillAppear(_ animated: Bool) {
        logScreenName()
        super.viewWillAppear(animated)
        
        populateSection1()
        
        if let ipValue = HubIpOverride.overrideIpAddress {
            hubIPTextField.text = ipValue
        }
        
        connectViaIPSwitch.isOn = HubIpOverride.shouldOverrideHubIp
        enableIPSection(enabled: connectViaIPSwitch.isOn)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IPConnectionViewController.updateOverrideState()
    }
    
    private func populateSection1() {
        gatewayAddressValue.text = WiFi.getGatewayAddress()
        thisDeviceIPValue.text = WiFi.getWiFiAddress()
    }
    
    @IBAction func connectToHubViaIPSwitchChanged(_ sender: UISwitch) {
        enableIPSection(enabled: sender.isOn)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        updateSettings()
        IPConnectionViewController.updateOverrideState()
        
        if HubDataModel.shared.connectedVeeaHub == nil {
            let fakeHub = VeeaHubConnection()
            HubDataModel.shared.connectedVeeaHub = fakeHub
        }
        
        HubDataModel.shared.nilAllDataMembers()
        
        self.dismiss(animated: true)
    }
    
    @IBAction func testConnectionTapped(_ sender: Any) {
        updateSettings()
        
        IPConnectionViewController.updateOverrideState()
        
        requestCount = 0
        makeRequest()
    }
    
    private func updateSettings() {
        HubIpOverride.overrideIpAddress = hubIPTextField.text
        HubIpOverride.shouldOverrideHubIp = connectViaIPSwitch.isOn
    }
    
    private func enableIPSection(enabled: Bool) {
        hubIPTextField.isUserInteractionEnabled = enabled
        hubIPTextField.isEnabled = enabled
        testConnectionKey.isUserInteractionEnabled = enabled
        testConnectionKey.isEnabled = enabled
        testConnectionValue.isUserInteractionEnabled = enabled
        testConnectionValue.isEnabled = enabled
    }
    
    public static func updateOverrideState() {        
        WiFi.shouldOverideGateway = HubIpOverride.shouldOverrideHubIp
        WiFi.overrideIPAddress = HubIpOverride.overrideIpAddress ?? ""
    }
}

// MARK: - Test Connection

extension IPConnectionViewController {
    private func makeRequest() {
        //print("Making manual config request")
        ApiFactory.api.getNodeConfig(connection: VeeaHubConnection()) {  [weak self]  (nodeConfig, error) in
            if error != nil {
                // The first request may fail as the auth will fail. Reset then try again
                
                //print("Manual config request returned error: \(error.localizedDescription)")
                                if (self?.requestCount)! <= 2 {
                    self?.requestCount += 1
                    let delay = DispatchTime.now() + .seconds(1)
                    DispatchQueue.main.asyncAfter(deadline: delay) {
                        //print("Attempt \(self?.requestCount ?? -1)")
                        self?.makeRequest()
                    }
                }
                else {
                    self?.testConnectionValue.text = "Error".localized()
                }
            }
            
            if nodeConfig?.node_name != nil {
                self?.testConnectionValue.text = "Success".localized()
                HubDataModel.shared.updateConfigInfo(observer: nil)
                
                return
            }
        }
    }
}
