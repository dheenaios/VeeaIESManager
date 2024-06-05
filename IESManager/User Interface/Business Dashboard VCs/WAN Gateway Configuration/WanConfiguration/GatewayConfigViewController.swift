//
//  GatewayConfigViewController.swift
//  VeeaHub Manager
//
//  Created by Al on 09/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit

class GatewayConfigViewController: BaseConfigTableViewController, AnalyticsScreenViewEventProtocol {

    var screenName: AnalyticsEvents.ScreenNames = .wan_settings_screen

    
    var updateDelegate: WanGatewayTabViewControllerDelegate?
    var vm = GatewayConfigViewModel()
    var longPressGR: UILongPressGestureRecognizer!
    var initialLockValues = [GatewayLock]()
    
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inlineHelpView.setText(labelText: "Configure up to four LANs on the VeeaHub network. Use this screen to link your AP settings with your WAN settings.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
        
        DispatchQueue.main.async {
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.stopEditing))
            doubleTap.numberOfTapsRequired = 2
            self.tableView.addGestureRecognizer(doubleTap)
            
            if !self.vm.isMN {
                self.longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(self.startEditing))
                self.tableView.addGestureRecognizer(self.longPressGR)
            }
            
            // SW-3063: copy initial values in case user declines any changes made
            for lock in self.vm.gatewayConfig!.locks {
                self.initialLockValues.append(GatewayLock(from: lock))
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .wan_configuration, push: true)
    }
    
    @objc func startEditing(recogniser: UILongPressGestureRecognizer) {
        guard let tableView = tableView else {
            return
        }
        
        if recogniser.state == .began && !tableView.isEditing {
            if let longPress = longPressGR {
                longPress.isEnabled = false
                tableView.setEditing(true, animated: true)
            }
        }
    }
    
    @objc func stopEditing(recogniser: UITapGestureRecognizer) {
        guard let tableView = tableView else {
            return
        }
        
        if recogniser.state == .ended {
            if let longPress = longPressGR {
                longPress.isEnabled = true
                tableView.setEditing(false, animated: true)
            }
        }
    }
        
    public func buildConfirmationMessage() -> String? {
        var message = ""
        let restrictedInterfaces = vm.unrestrictedInterfaces
        
        if vm.hasRestricted {
            message.append("The following interface(s): ".localized())
            message.append(restrictedInterfaces)
            message.append("are set to restricted operation. When using these interfaces this will reduce control traffic between the edge and cloud servers but limits management and status reporting. Specifically, you will not be able to download new images to edge servers which may also prevent new edge servers from joining the network.\n".localized())
        }
        
        if vm.hasUnrestricted {
            
            // Only show the unrestricted message if we are using cellular
            if !restrictedInterfaces.lowercased().contains("cell") {
                return nil
            }
            
            message.append("\nThe following interface(s): ".localized())
            message.append(restrictedInterfaces)
            message.append("are set to unrestricted operation. If your network provider charges for data usage these interface(s) this may incur significant charges.\n".localized())
        }

        message.append("\nDo you wish to proceed with the above backhaul configuration".localized())
        if vm.hasUnrestricted {
            message.append(" accepting that significant charges may occur due to some interfaces being unrestricted".localized())
        }
        message.append("?\n\nNote pressing CANCEL will revert the configuration which if it had enabled unrestricted interfaces may still incur significant additional charges.".localized())
        
        return message
    }
        
    func resetLockChanges() {
        vm.gatewayConfig!.locks = initialLockValues
    }
    
    var dataModelChanged: Bool {
        guard let originalJson = vm.gatewayConfig?.originalJson,
              let updatedJson = vm.gatewayConfig?.getUpdateJson() else {
            return false
        }
        
        do {
            let diff = try JsonDiffer.diffJson(original: originalJson,
                                               target: updatedJson)
            if !diff.isEmpty { return true }
        }
        catch {
            Logger.log(tag: "GatewayConfigViewController",
                       message: "Json Differ has thrown: \(error)")
        }
        
        if vm.originalNodeConfig != vm.nodeConfig {
            return true
        }
        
        return false
    }
}

extension GatewayConfigViewController: TitledPasswordFieldDelegate {
    func textDidChange(sender: TitledPasswordField) {
            guard let text = sender.text else { return }
        
        if sender.tagStr.isEmpty {
            if sender.tag == GatewayConfigViewModel.SettingsRowId.Passphrase {
                self.vm.gatewayConfig?.passphrase = text
            }
            
            updateDelegate?.viewControllersDataSetChanged(viewController: self)
            return
        }
        
        if sender.tag == GatewayConfigViewModel.SettingsRowId.apnPassphrase {
            self.vm.nodeConfig?.gateway_cellular_passphrase = text
        }
        
        updateDelegate?.viewControllersDataSetChanged(viewController: self)
    }
}

extension GatewayConfigViewController: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        guard let text = sender.text else { return }
        
        if sender.tagStr.isEmpty {
            if sender.tag == GatewayConfigViewModel.SettingsRowId.SSID {
                self.vm.gatewayConfig?.ssid = text
            }
            updateDelegate?.viewControllersDataSetChanged(viewController: self)
            return
        }
        
        if sender.tag == GatewayConfigViewModel.SettingsRowId.apnMcc {
            sender.setErrorLabel(message: self.vm.validateMncMccFields(text: text))
            self.vm.nodeConfig?.gateway_cellular_mcc = text
        }
        if sender.tag == GatewayConfigViewModel.SettingsRowId.apnMnc {
            sender.setErrorLabel(message: self.vm.validateMncMccFields(text: text))
            self.vm.nodeConfig?.gateway_cellular_mnc = text
        }
        
        if sender.tag == GatewayConfigViewModel.SettingsRowId.apnName {
            self.vm.nodeConfig?.gateway_cellular_apn = text
        }
        if sender.tag == GatewayConfigViewModel.SettingsRowId.apnUserName {
            self.vm.nodeConfig?.gateway_cellular_username = text
        }
        
        updateDelegate?.viewControllersDataSetChanged(viewController: self)
    }
}

extension GatewayConfigViewController: SettingsSwitchCellDelegate {
    func settingChanged(isEnabled: Bool) {
        
        // Only used for the MDEN Enabled flag
        vm.gatewayConfig?.gatewayServiceDiscovery = isEnabled
    }
}

extension GatewayConfigViewController: BackhaulCellDelegate {
    func enabledChanged(to: Bool, cell: BackhaulCell, completion: @escaping BackhaulCellToggleCallback) {
        if to == true {
            var title = "Enabling ".localized()
            var message = cell.lock.title
            
            if cell.restrictedSwitch.isOn {
                title.append("Restricted ".localized())
                message.append(" backhaul is being enabled and is currently set to restricted operation. Restricted operation reduces control traffic between the edge and cloud servers and so minimises costs if your network provider charges for data usage but limits management and status reporting. Specifically, you will not be able to download new images to edge servers which may also prevent new edge servers from joining the network. Do you wish to proceed with this backhaul enabled?".localized())
            } else {
                // VHM-51 Dialog only show this if its cellular data.
                if message.lowercased() == "Ethernet".lowercased() || message.lowercased() == "Wifi".lowercased() {
                    completion(true)
                    updateDelegate?.viewControllersDataSetChanged(viewController: self)
                    return
                }
                
                title.append("Unrestricted ".localized())
                message.append(" backhaul is being enabled and is currently set to unrestricted operation. If your network provider charges for data usage this may incur significant charges on this interface. Do you wish to proceed with this backhaul enabled?".localized())
            }
            
            title.append(cell.lock.title)

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel, handler: { action in
                completion(false)
                self.updateDelegate?.viewControllersDataSetChanged(viewController: self)
            }))
            alert.addAction(UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { action in
                completion(true)
                self.updateDelegate?.viewControllersDataSetChanged(viewController: self)
            }))
            
            present(alert, animated: true)
            
        } else {
            completion(true) // allow switch to be toggled
            self.updateDelegate?.viewControllersDataSetChanged(viewController: self)
        }
    }
    
    func restrictedChanged(to: Bool, cell: BackhaulCell, completion: @escaping BackhaulCellToggleCallback) {
        if !cell.lock.locked {
            var title: String
            var message = cell.lock.title
            
            if to == true {
                title = "Restricted ".localized()
                message.append(" backhaul is being configured for restricted operation. This reduces control traffic between the edge and cloud servers and so minimises costs if your network provider charges for data usage but limits management and status reporting. Specifically, you will not be able to download new images to edge servers which may also prevent new edge servers from joining the network. Do you wish to proceed with this backhaul restricted?".localized())
                
            }
            else {
                // VHM-51 Dialog only show this if its cellular data.
                if message.lowercased() == "Ethernet".lowercased() || message.lowercased() == "Wifi".lowercased() {
                    completion(true)
                    updateDelegate?.viewControllersDataSetChanged(viewController: self)
                    return
                }
                
                title = "Unrestricted ".localized()
                message.append(" backhaul is being configured for unrestricted operation. If your network provider charges for data usage this may incur significant charges on this interface. Do you wish to proceed with this backhaul unrestricted?".localized())
            }
            
            title.append(cell.lock.title)
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel, handler: { action in
                completion(false)
                self.updateDelegate?.viewControllersDataSetChanged(viewController: self)
            }))
            alert.addAction(UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { action in
                completion(true)
                self.updateDelegate?.viewControllersDataSetChanged(viewController: self)
            }))
            
            present(alert, animated: true)
            
        } else {
            completion(true) // allow switch to be toggled
            self.updateDelegate?.viewControllersDataSetChanged(viewController: self)
        }
    }
}

// MARK: - TableView Method Overrides
extension GatewayConfigViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if vm.shouldShowAPNSettings() {
            return vm.sectionTitles.count
        }
        
        return (vm.sectionTitles.count - 2)
    }
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case GatewayConfigViewModel.SectionId.SettingsWifi:
            return 2
        case GatewayConfigViewModel.SectionId.SettingsCellularRequested:
            return vm.shouldShowAPNSettings() ? 5 : 0
        case GatewayConfigViewModel.SectionId.SettingsCellularApplied:
            return vm.shouldShowAppliedAPNSettings() ? 6 : 0
        case GatewayConfigViewModel.SectionId.Backhaul:
            if let rows = vm.gatewayConfig?.locks.count {
                return rows + 1 // Add one for the header row
            }
            
            return 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vm.sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == GatewayConfigViewModel.SectionId.Backhaul || indexPath.section == GatewayConfigViewModel.SectionId.SettingsCellularApplied {
            return 50.0
        }
        else {
            return 90.0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == GatewayConfigViewModel.SectionId.Backhaul {
            if indexPath.row == 0 {
                // The header
                let cell = tableView.dequeueReusableCell(withIdentifier: "EnabledRestrictedCell", for: indexPath)
                return cell
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "BackhaulCell", for: indexPath) as! BackhaulCell
            let lock = vm.gatewayConfig!.locks[indexPath.row - 1]
            cell.fillWith(lock: lock,
                          isMN: vm.isMN)
            cell.delegate = self
            
            cell.accessoryType = vm.sdWanAvailable ? .disclosureIndicator : .none
            
            return cell
        }
        else if indexPath.section == GatewayConfigViewModel.SectionId.SettingsWifi {
            if indexPath.row == GatewayConfigViewModel.SettingsRowId.Passphrase {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell", for: indexPath) as! PasswordCell
                cell.titledField.tag = GatewayConfigViewModel.SettingsRowId.Passphrase
                cell.titledField.title = "PASSPHRASE".localized()
                cell.titledField.text = self.vm.gatewayConfig?.passphrase
                cell.titledField.delegate = self
                
                if HubDataModel.shared.isMN {
                    cell.contentView.isUserInteractionEnabled = false
                    cell.contentView.alpha = 0.3
                }
                
                return cell
            }
            else if indexPath.row == GatewayConfigViewModel.SettingsRowId.SSID {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
                cell.titledField.tag = GatewayConfigViewModel.SettingsRowId.SSID
                cell.titledField.title = "SSID".localized()
                cell.titledField.text = self.vm.gatewayConfig?.ssid
                cell.titledField.delegate = self
                
                if HubDataModel.shared.isMN {
                    cell.contentView.isUserInteractionEnabled = false
                    cell.contentView.alpha = 0.3
                }
                
                return cell
            }
        }
        else if indexPath.section == GatewayConfigViewModel.SectionId.SettingsCellularRequested {
           return cellularRequestedCell(indexPath: indexPath)
        }
        
        return cellularAppliedCell(indexPath: indexPath)
    }
    
    private func cellularAppliedCell(indexPath: IndexPath) -> UITableViewCell {
        let r = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.detailTextLabel?.numberOfLines = 2
        
        if r == GatewayConfigViewModel.SettingsRowId.connectedStatus {
            cell.textLabel?.text = "Connected Status".localized()
            cell.detailTextLabel?.text = vm.iesStatus?.gateway_cellular_connected_status
        }
        if r == GatewayConfigViewModel.SettingsRowId.connectedApn {
            cell.textLabel?.text = "Connected APN".localized()
            cell.detailTextLabel?.text = vm.iesStatus?.gateway_cellular_connected_apn
        }
        if r == GatewayConfigViewModel.SettingsRowId.connectedMcc {
            cell.textLabel?.text = "Connected MCC".localized()
            cell.detailTextLabel?.text = vm.iesStatus?.gateway_cellular_connected_mcc
        }
        if r == GatewayConfigViewModel.SettingsRowId.connectedMnc {
            cell.textLabel?.text = "Connected MNC".localized()
            cell.detailTextLabel?.text = vm.iesStatus?.gateway_cellular_connected_mnc
        }
        if r == GatewayConfigViewModel.SettingsRowId.connectedUsername {
            cell.textLabel?.text = "Connected Username".localized()
            cell.detailTextLabel?.text = vm.iesStatus?.gateway_cellular_connected_username
        }
        if r == GatewayConfigViewModel.SettingsRowId.connectedPassphrase {
            cell.textLabel?.text = "Connected Passphrase".localized()
            cell.detailTextLabel?.text = vm.iesStatus?.gateway_cellular_connected_passphrase
        }
        
        return cell
    }
    
    private func cellularRequestedCell(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == GatewayConfigViewModel.SettingsRowId.apnName {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            cell.titledField.tag = GatewayConfigViewModel.SettingsRowId.apnName
            cell.titledField.tagStr = "apn"
            cell.titledField.title = "APN NAME".localized()
            cell.titledField.text = self.vm.nodeConfig?.gateway_cellular_apn
            cell.titledField.delegate = self
            
            return cell
        }
        
        else if indexPath.row == GatewayConfigViewModel.SettingsRowId.apnMcc {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            cell.titledField.tag = GatewayConfigViewModel.SettingsRowId.apnMcc
            cell.titledField.tagStr = "mcc"
            cell.titledField.title = "APN MCC".localized()
            cell.titledField.setKeyboardType(type: .numberPad)
            cell.titledField.text = self.vm.nodeConfig?.gateway_cellular_mcc
            cell.titledField.delegate = self
            
            return cell
        }
        
        else if indexPath.row == GatewayConfigViewModel.SettingsRowId.apnMnc {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            cell.titledField.tag = GatewayConfigViewModel.SettingsRowId.apnMnc
            cell.titledField.tagStr = "mnc"
            cell.titledField.title = "APN MNC".localized()
            cell.titledField.setKeyboardType(type: .numberPad)
            cell.titledField.text = self.vm.nodeConfig?.gateway_cellular_mnc
            cell.titledField.delegate = self
            
            return cell
        }
        
        else if indexPath.row == GatewayConfigViewModel.SettingsRowId.apnUserName {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            cell.titledField.tag = GatewayConfigViewModel.SettingsRowId.apnUserName
            cell.titledField.tagStr = "apn"
            cell.titledField.title = "APN USERNAME".localized()
            cell.titledField.text = self.vm.nodeConfig?.gateway_cellular_username
            cell.titledField.delegate = self
            
            return cell
        }
        
        // Passphrase
        let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell", for: indexPath) as! PasswordCell
        
        cell.titledField.tag = GatewayConfigViewModel.SettingsRowId.apnPassphrase
        cell.titledField.tagStr = "apn"
        cell.titledField.title = "APN PASSPHRASE".localized()
        cell.titledField.text = self.vm.nodeConfig?.gateway_cellular_passphrase
        cell.titledField.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        if indexPath.section == GatewayConfigViewModel.SectionId.Backhaul {
            if let lockTitle = vm.gatewayConfig?.locks.at(index: (indexPath.row - 1)) {
                handleBackHaulSelection(type: lockTitle.title)
            }
        }
    }
        
    // only allow reordering of backhaul section
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == GatewayConfigViewModel.SectionId.Backhaul && indexPath.row != 0
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == GatewayConfigViewModel.SectionId.Backhaul && indexPath.row != 0
    }
    
    // suppress "-" button
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    // suppress "-" button
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if destinationIndexPath.row == 0 {
            resetLockChanges()
        }
        else {
            let fromLock = (vm.gatewayConfig?.locks.remove(at: sourceIndexPath.row - 1))!
            vm.gatewayConfig?.locks.insert(fromLock, at: destinationIndexPath.row - 1)
            
            for lock in vm.gatewayConfig!.locks {
                NSLog(lock.debugDescription())
            }
        }
        
        updateDelegate?.viewControllersDataSetChanged(viewController: self)
    }

    // prevent cell from being dragged out of its section
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        } else {
            if (proposedDestinationIndexPath.row == 0) {
                return sourceIndexPath
            }
            return proposedDestinationIndexPath
        }
    }
}

// MARK: - SD-WAN
extension GatewayConfigViewController {
    private func handleBackHaulSelection(type: String) {
        if let vc = vm.viewControllerForBackHaulSelection(type: type) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// Just a wrapper for the titled field
class SettingsCell: UITableViewCell {
    @IBOutlet weak var titledField: TitledTextField!
}

class PasswordCell: UITableViewCell {
    @IBOutlet weak var titledField: TitledPasswordField!
}
