//
//  ProviderSelectionTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 17/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit


class ProviderSelectionTableViewController: BaseConfigTableViewController, HubInteractionFlowControllerProtocol {
    var flowController: HubInteractionFlowController?
    
    var vm = ProviderSelectionViewModel()
    
    private static let expandedCellHeight: CGFloat = 140.0
    private static let collapsedCellHeight: CGFloat = 0.0
    
    @IBOutlet var cellBrandingImages: [UIImageView]!
    @IBOutlet var cellProviderNameLabels: [UILabel]!
    @IBOutlet var callServiceDescriptionLabels: [UILabel]!
    
    var selectedOperator: String?
    var allowedOperators: [String]?
    
    @IBOutlet var cells: [UITableViewCell]!
    
    private func updateSelectedCell() {
        for (index, cell) in cells.enumerated() {
            let operatorOption = ProviderSelectionViewModel.OperatorOptions(rawValue: index)!
            
            if operatorOption.supplierIdString() == selectedOperator {
                cell.accessoryType = .checkmark
                continue
            }
            
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    private func updateBrandingToVeeaFiIfNessesary() {
        let veeaFiImage = UIImage.init(named: "public_wifi_provider_veeaFi")
        
        if VeeaFiController.providerBrandingShouldBeVeeaFi(provider: ProviderSelectionViewModel.OperatorOptions.Socifi.supplierIdString()) {
            let imageView = cellBrandingImages[ProviderSelectionViewModel.OperatorOptions.Socifi.rawValue]
            imageView.image = veeaFiImage
        }
        if VeeaFiController.providerBrandingShouldBeVeeaFi(provider: ProviderSelectionViewModel.OperatorOptions.Purple.supplierIdString()) {
            let imageView = cellBrandingImages[ProviderSelectionViewModel.OperatorOptions.Purple.rawValue]
            imageView.image = veeaFiImage
        }
        if VeeaFiController.providerBrandingShouldBeVeeaFi(provider: ProviderSelectionViewModel.OperatorOptions.Hotspot.supplierIdString()) {
            let imageView = cellBrandingImages[ProviderSelectionViewModel.OperatorOptions.Hotspot.rawValue]
            imageView.image = veeaFiImage
        }
        
        if VeeaFiController.providerBrandingShouldBeVeeaFi(provider: ProviderSelectionViewModel.OperatorOptions.Hotspot.supplierIdString()) {
            let imageView = cellBrandingImages[ProviderSelectionViewModel.OperatorOptions.GlobalReach.rawValue]
            imageView.image = veeaFiImage
        }
    }
    
    // MARK: - Navigations
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let operators = vm.publicWifiConfig else {
            return
        }
        
        let operatorConfigs = operators.wifiOperators
        let segueID = segue.identifier
        
        for config in operatorConfigs {
            if config.supplierName == segueID {
                if let vc = segue.destination as? ProviderConfigurationTableViewController {
                    vc.selectedDefaultProviderDetails = config
                    vc.isTheCurrentlySelectedProvider = selectedOperator == segueID
                    
                    break
                }
            }
        }
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedOperator = vm.publicWifiSettings?.selected_operator
        allowedOperators = vm.publicWifiSettings?.allowed_operators
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectedCell()
        updateBrandingToVeeaFiIfNessesary()
    }
    
    // MARK: - TableView Override
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        
        guard let allowedOperators = allowedOperators else {
            return ProviderSelectionTableViewController.collapsedCellHeight
        }
        
        if row == ProviderSelectionViewModel.OperatorOptions.Socifi.rawValue {
            if allowedOperators.contains(ProviderSelectionViewModel.OperatorOptions.Socifi.supplierIdString()) {
                return ProviderSelectionTableViewController.expandedCellHeight
            }
        }
        else if row == ProviderSelectionViewModel.OperatorOptions.Purple.rawValue {
            if allowedOperators.contains(ProviderSelectionViewModel.OperatorOptions.Purple.supplierIdString()) {
                return ProviderSelectionTableViewController.expandedCellHeight
            }
        }
        else if row == ProviderSelectionViewModel.OperatorOptions.Hotspot.rawValue {
            if allowedOperators.contains(ProviderSelectionViewModel.OperatorOptions.Hotspot.supplierIdString()) {
                return ProviderSelectionTableViewController.expandedCellHeight
            }
        }
        else if row == ProviderSelectionViewModel.OperatorOptions.GlobalReach.rawValue {
            if allowedOperators.contains(ProviderSelectionViewModel.OperatorOptions.GlobalReach.supplierIdString()) {
                return ProviderSelectionTableViewController.expandedCellHeight
            }
        }
        
        return ProviderSelectionTableViewController.collapsedCellHeight
    }
    
    
    
    // Show only the items that are in the allowed operators array
    
    // Tick next to the selected item
    
    // Handle selections.
    
    
}
