//
//  SelectGroupViewController.swift
//  VeeaHub Manager
//
//  Created by Bajirao Bhosale on 01/06/21.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

protocol GroupSelectorDelegate {
    func didChooseGroup(with group: GroupModel)
}

class SelectGroupViewController: VUIViewController {

    var tableView: UITableView!
    var tableDataSource = SelectGroupDataSource()
    var delegate: GroupSelectorDelegate?
    
    convenience init(groupsVM: GroupsViewModel) {
        self.init()
        self.tableDataSource.groupVM = groupsVM
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonTitle()
        
        let titleString = "Select a Group".localized()
        self.title = titleString
        
        let titleView = TitleViewWithImage(icon: UIImage(named: "OnboardingStepGroupSelection"),title: titleString, subtext: "Each mesh must belong to a group, even if you have only one. Please select a group for this VeeaHub and its mesh to join.".localized())
        titleView.frame.origin.y = UIConstants.Margin.top + self.navbarMaxY
        self.view.addSubview(titleView)
        
        let tableOrigin = (titleView.bottomEdge + UIConstants.Margin.top)
        let tableHeight = self.view.bounds.height - self.navbarMaxY - tableOrigin
        tableView = UITableView(frame: CGRect(x: 0, y: tableOrigin, width: self.view.bounds.width, height: tableHeight), style: .grouped)
        tableView.backgroundColor = .clear
        tableView.dataSource = tableDataSource
        tableView.delegate = self
        self.view.addSubview(tableView)
    }
    
}


extension SelectGroupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let gVM = self.tableDataSource.groupVM {
            delegate?.didChooseGroup(with: gVM.groups![indexPath.row])
        }
        
        /*
        let meshCount = ((tableView.dataSource as? SelectMeshDataSource)?.meshes?.count ?? 0)
        if indexPath.row >= meshCount || indexPath.row == 0 && meshCount == 0 {
            self.delegate?.createNewMesh()
        } else {
            if let meshes_ = self.tableDataSource.meshes {
                var selected = meshes_[indexPath.row]

                if let enrollmentFlowCord = delegate as? EnrollmentFlowCoordinator {
                    var deviceMEN = VHMeshNode()
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
                            showAlert(with: "", message: "Your manager node is not ready, Please try again in a few minutes")
                        } else if VHDeviceType.getType(for: deviceMEN.id.split(from: 0, to: 2)) == VHDeviceType.vhc05 && enrollmentFlowCord.enrollmentData.model != VHDeviceType.vhc05.description {
                            showAlert(with: "", message: "Unable to add the VeeaHub to the mesh due to hardware incompatibility with Manager Node. Please create a new mesh or try to add to a different mesh")
                        }
                        else {
                            self.delegate?.didChooseMesh(with: selected)
                        }
                    }
                }
            }
        }
         */
    }
}
