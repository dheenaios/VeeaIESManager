//
//  WanStaticIpsViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 16/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit


class WanStaticIpsViewController: BaseConfigViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .wan_settings_screen


    let vm = WanStaticIpsViewModel()
    var updateDelegate: WanGatewayTabViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet private weak var modelsTableView: UITableView!
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    private var selectedWan = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
        
        inlineHelpView.setText(labelText: "Configure a reserved (fixed) IP address for the gateway VeeaHub. This is usually necessary only when the WAN does not have a DHCP server.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .wan_reserved_ips, push: true)
    }
    
    var dataModelChanged: Bool {
        return vm.needsUpdate
    }
}

extension WanStaticIpsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WanStaticIpCell
        
        let model = vm.editableModels[indexPath.row]
        cell.populate(model: model, cellIndex: indexPath.row)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.editableModels.count
    }
}

extension WanStaticIpsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedWan {
            return 460
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return vm.reasonNotToShow
    }
}

extension WanStaticIpsViewController: WanStaticIpCellDelegate {
    func cellUpdateChanged(index: Int, updatedModel: LanWanStaticIpConfig) {
        vm.models?[index] = updatedModel
        updateDelegate?.viewControllersDataSetChanged(viewController: self)
    }
}

extension WanStaticIpsViewController: WanAwareGatewayChildControllerDelegate {
    func childDidBecomeActive() {
        selectedWan = updateDelegate?.selectedWan ?? 0
        tableView.reloadData()
    }
    
    func wanDidChange(wan: Int) {
        selectedWan = wan
        tableView.reloadData()
    }
}
