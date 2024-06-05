//
//  WanInterfaceConfigurationView.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 25/03/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

protocol WanInterfaceConfigurationViewDelegate {
    func portInterfaceButtonTapped(view: WanInterfaceConfigurationView)
    func portSelectionChanged(view: WanInterfaceConfigurationView)
    func interfaceSelectionChanged(view: WanInterfaceConfigurationView)
    func dataModelChanged(view: WanInterfaceConfigurationView)
}

class WanInterfaceConfigurationView: UIView {

    public var delegate: WanInterfaceConfigurationViewDelegate?
    
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var wanNameField: TitledTextField!
    @IBOutlet weak var vlanTagField: TitledTextField!
    @IBOutlet weak var portLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var portButton: UIButton!
    @IBOutlet weak var pickerHeightConstraint: NSLayoutConstraint!
    
    private var initialWanConfig: WanConfig?
    private var wanConfig: WanConfig?
    private var wanInterfaceNumber = -1
    private var activePort = 0
    private var activeEthInterface = WanConfig.ActiveInterface.NONE

    
    @IBAction func portTapped(_ sender: Any) {
        delegate?.portInterfaceButtonTapped(view: self)
    }
    
    @IBAction func activeSwitchChanged(_ sender: UISwitch) {
        controlsEnabled(enabled: sender.isOn)
        delegate?.dataModelChanged(view: self)
    }
    
    private func controlsEnabled(enabled: Bool) {
        wanNameField.isUserInteractionEnabled = enabled
        portButton.isEnabled = enabled
        vlanTagField.isUserInteractionEnabled = enabled
        
        let alpha: CGFloat = enabled ? 1.0 : 0.3
        wanNameField.alpha = alpha
        vlanTagField.alpha = alpha
    }
    
    public func populateView(config: WanConfig?, wanNumber: Int) {
        guard let config = config else {
            return
        }
        
        picker.delegate = self

        wanInterfaceNumber = wanNumber
        wanConfig = config
        initialWanConfig = config
        
        activeSwitch.isOn = config.use
        wanNameField.title = "WAN NAME".localized()
        wanNameField.text = config.name
        wanNameField.delegate = self
        
        vlanTagField.title = "WLAN TAG".localized()
        vlanTagField.text = String(config.vlan_tag)
        vlanTagField.setKeyboardType(type: .numberPad)
        vlanTagField.delegate = self
        
        // Set the spinner to use PORTS or INTERFACES
        activePort = config.port
        activeEthInterface = config.activeInterface
        
        
        if hubHasWanConfig {
            setSpinnerForPorts(config: config)
        }
        else {
            setSpinnerForInterfaces(config: config)
        }
        
        controlsEnabled(enabled: config.use)
    }
    
    private func setSpinnerForInterfaces(config: WanConfig) {
        if activeEthInterface == .ETH0 {
            picker.selectRow(0, inComponent: 0, animated: false)
        }
        else if activeEthInterface == .ETH1 {
            picker.selectRow(1, inComponent: 0, animated: false)
        }
        
        updateEthInterfaceInfo()
    }
    
    private func setSpinnerForPorts(config: WanConfig) {
        picker.selectRow(activePort, inComponent: 0, animated: false)
        updatePortInfo()
    }
    
    private lazy var hubHasWanConfig: Bool = {
        guard let nodeCaps = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig else {
            return false
        }
        
        let configs = nodeCaps.ethernetConfigs
        return configs.contains(.WAN)
    }()
    
    private func updatePortInfo() {
        if activePort == 0 {
            portLabel.text = "No active port".localized()
            return
        }
        
        portLabel.text = "\(activePort)"
    }
    
    private func updateEthInterfaceInfo() {
        if activeEthInterface == .ETH0 {
            portLabel.text = "eth0 active".localized()
        }
        else if activeEthInterface == .ETH1 {
            portLabel.text = "eth1 active".localized()
        }
        else {
            portLabel.text = "No active interface".localized()
        }
    }
    
    /// Returns the current settings for the wan
    ///
    /// - Returns: WanConfig
    public func getWanConfig() -> WanConfig? {
        //wanConfig?.position = wanInterfaceNumber
        wanConfig?.name = wanNameField.text ?? ""
        wanConfig?.use = activeSwitch.isOn
        
        if let vlanTag: Int = Int(vlanTagField.text!) {
            wanConfig?.vlan_tag = vlanTag
        }
        
        wanConfig?.port = activePort
        wanConfig?.activeInterface = activeEthInterface
        
        return wanConfig
    }
    
    public var valuesHaveChanged: Bool {
        get {
            let changed = initialWanConfig != getWanConfig()
            
            return changed
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super .awakeFromNib()
        rootView = Bundle.main.loadNibNamed("WanInterfaceConfigurationView", owner: self, options: nil)![0] as? UIView
        rootView?.frame = bounds
        addSubview(rootView!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rootView = Bundle.main.loadNibNamed("WanInterfaceConfigurationView", owner: self, options: nil)![0] as? UIView
        rootView?.frame = bounds
        addSubview(rootView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Picker View Delegates
extension WanInterfaceConfigurationView: UIPickerViewDelegate {
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if hubHasWanConfig {
            if row == 0 {
                return "No active port".localized()
            }
            
            return "\("Port".localized()) \(row)"
        }
        else {
            return "\("eth".localized())\(row)"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if hubHasWanConfig {
            activePort = row
            updatePortInfo()
            delegate?.portSelectionChanged(view: self)
        }
        else {
            if row == 0 {
                activeEthInterface = .ETH0
            }
            else if row == 1 {
                activeEthInterface = .ETH1
            }
            else {
                activeEthInterface = .NONE
            }
            
            updateEthInterfaceInfo()
            delegate?.interfaceSelectionChanged(view: self)
        }
        
        delegate?.dataModelChanged(view: self)
    }
}

extension WanInterfaceConfigurationView: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        delegate?.dataModelChanged(view: self)
    }
}

extension WanInterfaceConfigurationView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if hubHasWanConfig {
            if let ports = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.numberOfEthernetPortsAvailable {
                return ports + 1
            }
            
            return 0
        }
        else {
            return 2 // eth0 and eth1
        }
    }
}
