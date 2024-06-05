//
//  SnapShottingViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 22/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class SnapShottingViewController: UITableViewController {
    
    @IBOutlet weak var currentSnapShotCell: UITableViewCell!
    @IBOutlet weak var clearSnapshotCell: UITableViewCell!
    @IBOutlet var statusLabels: [UILabel]!
    
    //Active Cell
    @IBOutlet weak var snapshotNameCell: UITableViewCell!
    @IBOutlet weak var snapshotNameLabel: UILabel!
    @IBOutlet weak var snapShotActiveLabel: UILabel!
    
    private func checkForSnapShotInfo() {
        let dm = HubDataModel.shared
        
        if let snapshot = dm.configurationSnapShotItem {
            statusCellsReadonly(readonly: false)
            
            let description = snapshot.snapShotDescription
            snapshotNameLabel.text = "Snapshot \"\(description ?? "with no description")\" loaded"
            setActiveText()
            
            return
        }
        
        statusCellsReadonly(readonly: true)
        snapshotNameLabel.text = "No snapshot loaded"
        snapShotActiveLabel.text = ""
    }
    
    private func setActiveText() {
        let active = HubDataModel.shared.snapShotInUse
        
        let stateToggle = active ? "inactive" : "active"
        let state = active ? "Active" : "Inactive"
        snapshotNameCell.accessoryType = active ? .checkmark : .none
        snapShotActiveLabel.text = "\(state) (Tap to make the snapshot \(stateToggle))"
    }
    
    private func toggleSnapshotActiveState() {
        HubDataModel.shared.snapShotInUse = !HubDataModel.shared.snapShotInUse
        setActiveText()
    }
    
    private func clearSnapShot() {
        let model = HubDataModel.shared
        model.snapShotInUse = false
        model.configurationSnapShotItem = nil
        snapshotNameCell.accessoryType = .none
        
        checkForSnapShotInfo()
    }
    
    private func pushToDashboard() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Dash", bundle: nil)
        if let dashboard = storyBoard.instantiateViewController(withIdentifier: "DashViewController") as? DashViewController {
            self.navigationController?.navigationBar.prefersLargeTitles = false
            self.navigationController?.show(dashboard, sender: nil)
        }
    }
    
    private func statusCellsReadonly(readonly: Bool) {
        currentSnapShotCell.isUserInteractionEnabled = !readonly
        clearSnapshotCell.isUserInteractionEnabled = !readonly
        
        for l in statusLabels {
            l.alpha = readonly ? 0.3 : 1.0
        }
    }
    
    // MARK: - TableView Override Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            if indexPath.row == 1 { // Toggle snapshot active
                toggleSnapshotActiveState()
            }
            if indexPath.row == 2 { // Clear snapshot
                clearSnapShot()
            }
            if indexPath.row == 3 { // Push to the dashboard
                pushToDashboard()
            }
        }
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Config Snapshots"
        statusCellsReadonly(readonly: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForSnapShotInfo()
    }
}
