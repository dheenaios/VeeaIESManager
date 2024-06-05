//
//  MasEndpointsTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 05/10/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class EndPointsTableViewController: UITableViewController {
    private struct SelectionSectionRows {
        static let prod = 0
        static let qa = 1
        static let dev = 2
        static let custom = 3
    }
    
    let endPointManager = EndPointConfigManager()
    
    var selectedRowType: EndPointConfigManager.EndPointType?
    
    @IBOutlet weak var enrollmentUrlField: UITextField!
    @IBOutlet weak var authUrlField: UITextField!
    @IBOutlet weak var masUrlField: UITextField!
    
    @IBOutlet var cells: [UITableViewCell]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
        
        if AuthorisationManager.shared.isLoggedIn {
            let alert = UIAlertController.init(title: "You are logged in",
                                               message: "Please log out to change the environment.\nTo log out, navigate to \"My Account\" and click on the \"Logout\" button.",
                                               preferredStyle: .alert)

            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }

    private func logout() {
        Task {
            let result = await LogoutController.logout()
            let success = result == LogoutController.LogoutResult.success
            await MainActor.run {
                if !success {
                    showAlert(with: "Error", message: "Could not log you out. Please try again later")
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        save()
    }
    
    private func save() {
        if AuthorisationManager.shared.isLoggedIn {
            return
        }
        
        AuthorisationManager.shared.reset()
        
        guard let type = selectedRowType,
              let eT = enrollmentUrlField.text,
              let aT = authUrlField.text,
              let mT = masUrlField.text else {
            return
        }
        
        let config = EndPointConfigManager.EndPointConfig.init(type: type,
                                                               enrollmentUrl: eT,
                                                               authUrl: aT,
                                                               masUrl: mT)
        endPointManager.setConfig(config: config)
    }
    
    private func load() {
        selectedRowType = endPointManager.currentConfig().type
        setTextFieldEditability(editable: selectedRowType == .custom)
        updateEndPointText()
    }
    
    private func setTextFieldEditability(editable: Bool) {
        let alpha: CGFloat = editable ? 1.0 : 0.3
    
        enrollmentUrlField.alpha = alpha
        authUrlField.alpha = alpha
        masUrlField.alpha = alpha
        
        enrollmentUrlField.isEnabled = editable
        authUrlField.isEnabled = editable
        masUrlField.isEnabled = editable
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            return
        }
        
        switch indexPath.row {
        case SelectionSectionRows.prod:
            selectedRowType = .production
            break
        case SelectionSectionRows.qa:
            selectedRowType = .qa
            break
        case SelectionSectionRows.dev:
            selectedRowType = .dev
            break
        case SelectionSectionRows.custom:
            selectedRowType = .custom
            break
        default:
            break
        }
        
        setTextFieldEditability(editable: selectedRowType == .custom)
        updateEndPointText()
    }
    
    private func updateEndPointText() {
        guard let selectedRowType = selectedRowType else {
            return
        }
        
        let config = endPointManager.getConfigFor(type: selectedRowType)
        
        enrollmentUrlField.text = config.enrollmentEndpoint
        authUrlField.text = config.authEndpointAndRealm
        masUrlField.text = config.masEndpoint
        
        updateCheckbox(selectedRowType: selectedRowType)
    }
    
    private func updateCheckbox(selectedRowType: EndPointConfigManager.EndPointType) {
        for cell in cells {
            cell.accessoryType = .none
        }
        
        let selectedCell = cells[selectedRowType.rawValue]
        selectedCell.accessoryType = .checkmark
    }
}
