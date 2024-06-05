//
//  ServicesViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 30/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit
import SharedBackendNetworking

class ServicesViewModel: BaseConfigViewModel {

    var packages: [VHMeshNodePackage]?
    
    var updateHandler: (() -> Void)?
    
    var numberOfServices: Int {
        guard let packages = packages else {
            return 0
        }
        
        return packages.count
    }
    
    init(updateHandler: @escaping () -> Void) {
        self.updateHandler = updateHandler
        super.init()
    }
    
    // MARK: - Selection Handling
    func handleSelected(package: VHMeshNodePackage, vc: ServicesViewController) {
        let sb = UIStoryboard(name: "Services", bundle: nil)
        let newVc = sb.instantiateViewController(withIdentifier: "ServiceDetailsViewController") as! ServiceDetailsViewController
        newVc.package = package
        vc.navigationController?.pushViewController(newVc, animated: true)
    }
}

// MARK: - Load services info from backend
extension ServicesViewModel {
    func loadAvailableServices() {
        guard let groupId = GroupModel.selectedModel?.id else {
            self.setNoPackages()
            return
        }

        if groupId.isEmpty {
            self.setNoPackages()
        }
        else {
            Task {
                let result = await EnrollmentService.getOwnerConfig(groupId: groupId)
                if let message = result.1 {
                    Logger.log(tag: "ServicesViewModel", message: "No packages returned: \(message)")
                }
                guard let meshes = result.0 else {
                    await MainActor.run { self.setNoPackages() }
                    return
                }

                await MainActor.run { self.setPackages(meshes: meshes) }
            }
        }
    }
    
    private func setPackages(meshes: [VHMesh]) {
        guard let serial = HubDataModel.shared.baseDataModel?.nodeInfoConfig?.unit_serial_number else {
            setNoPackages()
            return
        }

        if TestsRouter.interceptForMocking {
            setTestPackages(meshes: meshes)
            return
        }
        
        for mesh in meshes {
            if let devices = mesh.devices {
                for device in devices {
                    if device.id.lowercased() == serial.lowercased() {
                        if let packages = device.packages {
                            setPackageDetails(packages: packages)
                        }
                        else {
                            setNoPackages()
                        }
                    }
                }
            }
        }
    }

    private func setTestPackages(meshes: [VHMesh]) {
        for mesh in meshes {
            if let devices = mesh.devices {
                for device in devices {
                    if let packages = device.packages {
                        setPackageDetails(packages: packages)
                        return
                    }
                }
            }

            setNoPackages()
        }
    }
    
    private func setPackageDetails(packages: [VHMeshNodePackage]) {
        self.packages = packages.filter { $0.type != "Basic" }
        updateHandler!()
    }
    
    private func setNoPackages() {
        setPackageDetails(packages: [VHMeshNodePackage]())
        updateHandler!()
    }
}
