//
//  SelectMeshViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/17/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

protocol MeshSelectorDelegate {
    func didChooseMesh(with mesh: VHMesh)
    func createNewMesh()
}

class SelectMeshViewController: VUIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .enterprise_onboarding_screen
    var tableView: UITableView!
    var tableDataSource = SelectMeshDataSource()
    var delegate: MeshSelectorDelegate?
    var activity: UIActivityIndicatorView?
    
    var searchBar: UISearchBar!
        
    convenience init(meshes: [VHMesh]) {
        self.init()
        self.tableDataSource.meshes = meshes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonTitle()
        
        let titleString = "Select Mesh".localized()
        self.title = titleString
        
        let titleView = TitleViewWithImage(icon: UIImage(named: "OnboardingStepMeshSelection"),
                                           title: titleString,
                                           subtext: "Select the mesh you want to add this VeeaHub to. You can also choose to create a new mesh for this VeeaHub.".localized())
        titleView.frame.origin.y = UIConstants.Margin.top + self.navbarMaxY
        self.view.addSubview(titleView)
        
        let searchBar = addSearchBar(topView: titleView)
        
        let tableHeight = self.view.bounds.height - self.navbarMaxY - searchBar.bottomEdge
        tableView = UITableView(frame: CGRect(x: 0, y: searchBar.bottomEdge, width: self.view.bounds.width, height: tableHeight), style: .grouped)
        tableView.backgroundColor = .clear
        tableView.dataSource = tableDataSource
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        
        self.view.addSubview(tableView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }

    private func addSearchBar(topView: UIView) -> UISearchBar {
        let y = (topView.bottomEdge + UIConstants.Margin.top)
        searchBar = UISearchBar(frame: CGRect(x: 0, y: y, width: self.view.bounds.width, height: 44.0))
        searchBar.placeholder = "Search".localized()
        searchBar.tintColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
        searchBar.delegate = self
        searchBar.searchTextField.textColor = InterfaceManager.shared.cm.text1.colorForAppearance
        searchBar.searchTextField.leftView?.tintColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
        searchBar.accessibility(config: AccessibilityConfigurations.searchMeshTxtField)
        
        // Hide the boarder and seperator lines
        searchBar.layer.borderWidth = 0
        searchBar.layer.borderColor = UIColor.clear.cgColor
        searchBar.backgroundImage = UIImage()
        
        self.view.addSubview(searchBar)
        return searchBar
    }
}

extension SelectMeshViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableDataSource.searchTerm = searchText
        tableView.reloadData()
    }
}

extension SelectMeshViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let meshCount = ((tableView.dataSource as? SelectMeshDataSource)?.searchedMeshes?.count ?? 0)
        if indexPath.row >= meshCount || indexPath.row == 0 && meshCount == 0 {
            self.delegate?.createNewMesh()
        } else {
            if let meshes_ = self.tableDataSource.searchedMeshes {
                var selected = meshes_[indexPath.row]
                
                if let enrollmentFlowCord = delegate as? EnrollmentFlowCoordinator {
                    if var deviceMEN = selected.devices?[0] {
                        if selected.devices?.count == 1 {
                            // If only one device in the Mesh then this is MEN
                            selected.devices?[0].isMEN = true
                        }
                        
                        for device in selected.devices! {
                            if device.isMEN ?? false {
                                deviceMEN = device
                                break
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if deviceMEN.id == nil {
                                // Edge case: That is unlikely to occur
                                showAlert(with: "", message: "Your manager node is not ready, Please try again in a few minutes".localized())

                                return
                            }

                            let menModel = VeeaHubHardwareModel(serial: deviceMEN.id)
                            let mnModel = enrollmentFlowCord.enrollmentData.hardwareModel
                            if let compatabilityIssue = MeshHardwareIncompatability.add(mn: mnModel, toMenModel: menModel) {
                                if compatabilityIssue.totalIncompatibility {
                                    showAlert(with: "Warning", message: compatabilityIssue.message)
                                }
                                else {
                                    // Warning, but let them go ahead
                                    showAlertWithOkCancel(with: "Warning", message: compatabilityIssue.message) {
                                        self.delegate?.didChooseMesh(with: selected)
                                    }
                                }
                            }
                            else {
                                self.delegate?.didChooseMesh(with: selected)
                            }
                        }
                    } else {
                        //print("Mesh is empty")
                        DispatchQueue.main.async {showAlert(with: "", message: "Your manager node is not ready, Please try again in a few minutes".localized())}
                    }
                }
            }
        }
    }
}
