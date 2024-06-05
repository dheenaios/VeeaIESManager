//
//  TesterMenuRootTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 22/05/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SwiftUI
import SharedBackendNetworking

class TesterMenuRootTableViewController: UITableViewController {
    private struct MenuOptions {
        
        static let UserInterfaceSection = 0
        static let ConnectionRoutes = 1
        static let VeeaBackendSection = 2
        static let HubDiagnosticsSection = 3
        static let NofificationDetailsSection = 4
        
        struct UserInterfaceOptions {
            static let pushToDashboard = 0
            static let allowCountryChange = 1
            static let connectOnlyByBeacon = 2
        }

        struct ConnectionRoutesOptions {
            static let connectionRoutes = 0
            static let btScan = 1
        }
        
        struct VeeaBackend {
            static let endPoints = 0
            static let currentAuthDetails = 1
            static let alwaysConnectViaMas = 2
        }

        struct HubDiagnostics {
            static let debugLogs = 0
            static let ping = 1
            static let apiTests = 2
            static let snapshotting = 3
            static let networkCalls = 4
        }
    }
        
    var allowCountryChange = TesterMenuDataModel.UIOptions.allowCountryChange
    var connectOnlyViaBeacon = TesterMenuDataModel.UIOptions.connectOnlyViaBeacon
        
    @IBOutlet private weak var allowCountryChangeCell: UITableViewCell!
    @IBOutlet private weak var onlyConnectViaBeaconCell: UITableViewCell!
    @IBOutlet weak var connectViaMasWhenHubNotConnected: UITableViewCell!
    
    
    @IBOutlet weak var buildLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavBarWithDefaultColors()
        logScreenName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateTableView()
        updateBuildVersionLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    private func populateTableView() {
        populateUISection()
        populateVeeaBackendSection()
    }
    
    private func populateUISection() {
        allowCountryChangeCell.accessoryType = allowCountryChange ? .checkmark : .none
        onlyConnectViaBeaconCell.accessoryType = connectOnlyViaBeacon ? .checkmark : .none
    }
    
    private func populateVeeaBackendSection() {
        connectViaMasWhenHubNotConnected.accessoryType = TesterMenuDataModel.VeeaBackEndOptions.connectViaMasIfHubNotConnected ? .checkmark : .none
    }
    
    private func updateBuildVersionLabel() {
        buildLabel.text = "VHM: v\(Target.currentVersion)-\(Target.currentBundleString)"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == MenuOptions.UserInterfaceSection {
            if indexPath.row == MenuOptions.UserInterfaceOptions.pushToDashboard {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Dash", bundle: nil)
                if let dashboard = storyBoard.instantiateViewController(withIdentifier: "DashViewController") as? DashViewController {
                    self.navigationController?.navigationBar.prefersLargeTitles = false
                    self.navigationController?.show(dashboard, sender: nil)
                }
            }
            else if indexPath.row == MenuOptions.UserInterfaceOptions.allowCountryChange {
                allowCountryChange = !allowCountryChange
            }
            else if indexPath.row == MenuOptions.UserInterfaceOptions.connectOnlyByBeacon {
                connectOnlyViaBeacon = !connectOnlyViaBeacon
            }
            
            populateUISection()
        }

        else if indexPath.section == MenuOptions.ConnectionRoutes {
            if indexPath.row == MenuOptions.ConnectionRoutesOptions.btScan {
                //let vc = BtBeaconScannerView.inHostViewController()
                let vc = BtBeaconMeshSelectionView.inHostViewController()
                self.navigationController?.show(vc, sender: nil)
            }
        }
        
        else if indexPath.section == MenuOptions.VeeaBackendSection {
            if indexPath.row == MenuOptions.VeeaBackend.alwaysConnectViaMas {
                
                // Invert the selection
                let acccessory: UITableViewCell.AccessoryType = TesterMenuDataModel.VeeaBackEndOptions.connectViaMasIfHubNotConnected ? .none : .checkmark
                tableView.cellForRow(at: indexPath)?.accessoryType = acccessory
                
                TesterMenuDataModel.VeeaBackEndOptions.connectViaMasIfHubNotConnected = acccessory == .checkmark ? true : false
            }
        }
        else if indexPath.section == MenuOptions.HubDiagnosticsSection {
            if indexPath.row == MenuOptions.HubDiagnostics.networkCalls {
                let vc = HostingController(rootView: CallLogsView())
                self.navigationController?.show(vc, sender: nil)
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if navigationController?.viewControllers.count ?? 1 > 1 {
            navigationController?.popViewController(animated: true)
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func saveSettings() {
        TesterMenuDataModel.UIOptions.allowCountryChange = allowCountryChange
        TesterMenuDataModel.UIOptions.connectOnlyViaBeacon = connectOnlyViaBeacon
    }
}
