//
//  SecurityRadiusSelectionTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

class SecurityRadiusSelectionTableViewController: APSecurityBaseTableViewController {

    enum SecurityRadiusSelectionType: String {
        case authPrimary = "authPrimary"
        case authSecondary = "authSecondary"
        case acctPrimary = "acctPrimary"
        case acctSecondary = "acctSecondary"
    }
    
    var selectedIndex = -1
    var currentlyInUseSelectedServerIndex = -1 // The index of the server being used by the hub
    var serverType: SecurityRadiusSelectionType = .authPrimary
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setUp() {
        switch serverType {
        case .authPrimary:
            title = "Radius Auth Primary".localized()
            self.selectedIndex =  coordinator!.config.radius1_auth_id - 1
        case .authSecondary:
            title = "Radius Auth Secondary".localized()
            self.selectedIndex =  coordinator!.config.radius2_auth_id - 1
        case .acctPrimary:
            title = "Radius Acct Primary".localized()
            self.selectedIndex =  coordinator!.config.radius1_acct_id - 1
        case .acctSecondary:
            title = "Radius Acct Secondary".localized()
            self.selectedIndex =  coordinator!.config.radius2_acct_id - 1
        }
        
        currentlyInUseSelectedServerIndex = self.selectedIndex
    }
    
    
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? RadiusServerCell {
            if !cell.isConfigured {
                if HubDataModel.shared.isMN {
                    showInfoWarning(message: "This server is not configured. Servers can only be configured on the Management Node".localized())
                }
                else {
                    showInfoWarning(message: "This server is not configured. Tap the edit button to configure.".localized())
                }
                
                return
            }
        }
        
        // If tapping the selected row, we want to unselect it
        if selectedIndex == indexPath.section {
            selectedIndex = -1
            setRadiusId(id: 0)
        }
        else {
            if !isNotInUse(index: indexPath.section) {
                showInfoMessage(message: "\("This server".localized()) \(indexPath.section + 1) \("is already in use.".localized())")
                return
            }
            
            selectedIndex = indexPath.section
            setRadiusId(id: indexPath.section + 1)
        }
        
        tableView.reloadData()
    }
    
    private func setRadiusId(id: Int) {
        switch serverType {
        case .authPrimary:
            coordinator?.config.radius1_auth_id = id
        case .authSecondary:
            coordinator?.config.radius2_auth_id = id
        case .acctPrimary:
            coordinator?.config.radius1_acct_id = id
        case .acctSecondary:
            coordinator?.config.radius2_acct_id = id
        }
    }
    
    
    /// Checks if we can add. Is it selected elsewhere
    /// - Parameter index: The index to be added
    /// - Returns: Can it be added
    private func isNotInUse(index: Int) -> Bool {
        switch serverType {
        case .authPrimary:
            if let existing = coordinator?.config.radius2_auth_id {
                if existing == 0 { return true }
                if (index + 1) == existing {return false}
            }
        case .authSecondary:
            if let existing = coordinator?.config.radius1_auth_id {
                if existing == 0 { return true }
                if (index + 1) == existing {return false}
            }
        case .acctPrimary:
            if let existing = coordinator?.config.radius2_acct_id {
                if existing == 0 {
                    return true
                    
                }
                if (index + 1) == existing {
                    return false
                }
            }
        case .acctSecondary:
            if let existing = coordinator?.config.radius1_acct_id {
                if existing == 0 { return true }
                if (index + 1) == existing {return false}
            }
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RadiusServerCell
        
        cell.accessoryType = .none
        if indexPath.section == selectedIndex {
            cell.accessoryType = .checkmark
        }
        
        switch serverType {
        case .authPrimary, .authSecondary:
            if let model = coordinator?.meshRadiusConfig?.radiusAuthServers[indexPath.section] {
                cell.configure(model: model, index: indexPath.section)
            }
        case .acctPrimary, .acctSecondary:
            if let model = coordinator?.meshRadiusConfig?.radiusAcctServers[indexPath.section] {
                cell.configure(model: model, index: indexPath.section)
            }
        }
        
        cell.disabledAppearance(enabled: isNotInUse(index: indexPath.section))
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return "Radius Server \(section + 1)"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return coordinator!.radiusServers.count
    }
}

extension SecurityRadiusSelectionTableViewController: RadiusServerCellDelegate {
    func editTapped(model: RadiusServer, index: Int) {
        let vc = UIStoryboard(name: "WifiApSecurity", bundle: nil).instantiateViewController(withIdentifier: "SecurityEditRadiusTableViewController") as! SecurityEditRadiusTableViewController
        vc.vm.model = model
        vc.vm.radiusModelIndex = index
        vc.vm.isAuthServer = serverType == .authPrimary || serverType == .authSecondary
        vc.vm.isInUse = index == currentlyInUseSelectedServerIndex
        vc.vm.isCurrentlySelected = index == selectedIndex
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

fileprivate protocol RadiusServerCellDelegate: AnyObject {
    func editTapped(model: RadiusServer, index: Int)
}

class RadiusServerCell: UITableViewCell {
    fileprivate weak var delegate: RadiusServerCellDelegate?
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var secretLabel: UILabel!
    @IBOutlet weak var portLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    private var model: RadiusServer?
    private var index: Int?
    
    @IBAction func editButtonTapped(_ sender: Any) {
        if HubDataModel.shared.isMN { return }
        delegate?.editTapped(model: model!, index: index!)
    }
    
    func configure(model: RadiusServer, index: Int) {
        self.index = index
        self.model = model
        let addr = model.address.isEmpty ? "Not set".localized() : model.address
        let secr = model.secret.isEmpty ? "Not set".localized() : model.secret
        
        addressLabel.text = "Address: ".localized() + addr
        secretLabel.text = "Secret: ".localized() + secr
        portLabel.text = "Port: ".localized() + "\("model.port".localized())"
        
        setIsConfigured(enabled: model.isConfigured)
    }
    
    public var isConfigured: Bool {
        get { return model?.isConfigured ?? false }
    }
    
    private func setIsConfigured(enabled: Bool) {
        let alphaVal: CGFloat = enabled ? 1.0 : 0.3
        if HubDataModel.shared.isMN {
            editButton.isHidden = !enabled
            
            addressLabel.alpha = alphaVal
            secretLabel.alpha = alphaVal
            portLabel.alpha = alphaVal
        }
    }
    
    func disabledAppearance(enabled: Bool) {
        contentView.alpha = enabled ? 1.0 : 0.3
    }
}
