//
//  WiFiSettingsViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 18/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class HomeWiFiSettingsViewController: HomeUserBaseTableViewController {

    let vm = WiFiSettingsViewModel()
    
    private struct TableStructure {
        static let wifiName = IndexPath(row: 0, section: 0)
        static let pwd = IndexPath(row: 1, section: 0)
    }
    
    
    @IBOutlet weak var wifiNameLabel: UILabel!
    @IBOutlet weak var pwdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpValues()
    }
    
    private func setUpValues() {
        wifiNameLabel.text = vm.wifiName
        pwdLabel.text = vm.pwd
    }
    
    override func setTheme() {
        let cm = InterfaceManager.shared.cm
        
        let navbarColor = cm.background2
        tableView.backgroundColor = navbarColor.colorForAppearance
        setTitleItemBar(color: navbarColor, transparent: true)
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == TableStructure.wifiName {
            handleSsidSelection()
        }
        else if indexPath == TableStructure.pwd {
            handlePwdSelection()
        }
    }
    
    private func handleSsidSelection() {
        let vc = HomeEditSsidPwdViewController.new(mode: .ssid) { result, mode in
            self.handleSsidPwdEditResult(result: result, mode: mode)
        }
        
        let nc = UINavigationController(rootViewController: vc)
        
        vc.modalPresentationStyle = .pageSheet
        present(nc, animated: true, completion: nil)
    }
    
    private func handlePwdSelection() {
        let vc = HomeEditSsidPwdViewController.new(mode: .pwd) { result, mode in
            self.handleSsidPwdEditResult(result: result, mode: mode)
        }
        
        let nc = UINavigationController(rootViewController: vc)
        
        vc.modalPresentationStyle = .pageSheet
        present(nc, animated: true, completion: nil)
    }
    
    private func handleSsidPwdEditResult(result: String,
                                         mode: HomeEditSsidPwdViewController.HomeEditSsidPwdViewControllerMode) {
        if mode == .ssid {
            vm.ap.ssid = result
        }
        else {
            vm.ap.pass = result
        }
        
        setUpValues()
    }
}

class WiFiSettingsViewModel: HomeUserBaseViewModel {
    let circles = "•••••••••••"
    
    lazy var ap: AccessPointConfig = {
        for ap in HubDataModel.shared.baseDataModel!.meshAPConfig!.aps2ghz {
            if !ap.system_only {
                return ap
            }
        }
        
        return HubDataModel.shared.baseDataModel!.meshAPConfig!.ap_1_3 // We should never reach here
    }()
    
    var wifiName: String {
        ap.ssid
    }
    
    var pwd: String {
        //ap.pass
        circles
    }
}
