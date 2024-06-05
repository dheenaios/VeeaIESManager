//
//  WanInterfaceTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 08/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit


class WanInterfaceTableViewController: BaseConfigTableViewController, AnalyticsScreenViewEventProtocol {

    var screenName: AnalyticsEvents.ScreenNames = .wan_settings_screen

    
    var updateDelegate: WanGatewayTabViewControllerDelegate?
    
    private var selectedWan = 0
    private var cellIsOpen = false
    
    @IBOutlet weak var wanInterface1View: WanInterfaceConfigurationView?
    
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    private let cellOpenedHeight: CGFloat = 443
    private let cellClosedHeight: CGFloat = 281
    
    private lazy var originalConfigs: NodeWanConfig? = {
        return HubDataModel.shared.baseDataModel?.nodeWanConfig
    }()
    
    private lazy var wanConfigs: NodeWanConfig? = {
        return HubDataModel.shared.baseDataModel?.nodeWanConfig
    }()
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateWanViews()
        recordScreenAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wanInterface1View?.delegate = self
        
        inlineHelpView.setText(labelText: "Configure this screen to match the LAN settings section.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
    }
    
    private func populateWanViews() {
        guard let configs = wanConfigs else { return }
        
        let wans = [configs.wan_1, configs.wan_2, configs.wan_3, configs.wan_4]
        wanInterface1View?.populateView(config: wans[selectedWan], wanNumber: selectedWan + 1)
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .wan_interfaces, push: true)
    }
    
    public func shouldUpdate() -> Bool {
        updateConfig()
        
        return originalConfigs != wanConfigs
    }
    
    public func getNodeWanConfig() -> NodeWanConfig? {
        return wanConfigs
    }
    
    var dataModelChanged: Bool {
        return shouldUpdate()
    }
}

/// Tebleview related items
extension WanInterfaceTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        cellIsOpen = !cellIsOpen
        
        // Return the inverse of the value as we have just flipped it ready for the next time
        return cellIsOpen ? cellClosedHeight : cellOpenedHeight
    }
}

extension WanInterfaceTableViewController: WanInterfaceConfigurationViewDelegate {
    func dataModelChanged(view: WanInterfaceConfigurationView) {
        updateDelegate?.viewControllersDataSetChanged(viewController: self)
    }
    
    func interfaceSelectionChanged(view: WanInterfaceConfigurationView) {
        portSelectionChanged(view: view)
    }
    
    func portInterfaceButtonTapped(view: WanInterfaceConfigurationView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func portSelectionChanged(view: WanInterfaceConfigurationView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    private func updateConfig() {
        guard let updatedConfig = wanInterface1View?.getWanConfig() else { return }
        
        switch selectedWan {
        case 1:
            wanConfigs?.wan_2 = updatedConfig
            break
        case 2:
            wanConfigs?.wan_3 = updatedConfig
            break
        case 3:
            wanConfigs?.wan_4 = updatedConfig
            break
        default:
            wanConfigs?.wan_1 = updatedConfig
            break
        }
    }
}

extension WanInterfaceTableViewController: WanAwareGatewayChildControllerDelegate {
    func childDidBecomeActive() {
        selectedWan = updateDelegate?.selectedWan ?? 0
        populateWanViews()
    }
    
    func wanDidChange(wan: Int) {
        // Save the existing
        updateConfig()
        
        // Update the UI
        selectedWan = wan
        populateWanViews()
    }
}
