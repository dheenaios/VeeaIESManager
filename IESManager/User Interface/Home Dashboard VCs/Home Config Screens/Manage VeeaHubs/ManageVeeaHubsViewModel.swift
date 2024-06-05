//
//  ManageVeeaHubsViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 16/05/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import SwiftUI
import WidgetKit

import Foundation

class ManageVeeaHubsViewModel {
    let mesh: VHMesh
    private let meshDetailViewModel: MeshDetailViewModel

    var searchTerm: String = ""

    weak var delegate: MeshStateDelegate?

    init(mesh: VHMesh, meshDetailViewModel: MeshDetailViewModel) {
        self.mesh = mesh
        self.meshDetailViewModel = meshDetailViewModel
        self.meshDetailViewModel.delegate = self // Grab the delegate se we get infomed of the state updates
    }

    var numberOfDevices: Int {
        return nodeModelsForSearchTerm().count
    }

    func checkDataModelIsMen() {
        guard HubDataModel.shared.baseDataModel != nil else {
            return
        }

        if HubDataModel.shared.isMN {
            HubDataModel.shared.nilAllDataMembers()
        }
    }

    /// Result will be returned by the MeshStateDelegate
    func removeModel(model: NodeTableCellModel) {
        meshDetailViewModel.removeModel(model: model)
    }

    func nodeTableCellModelForIndex(_ index: Int) -> NodeTableCellModel {
        return nodeModelsForSearchTerm()[index]
    }

    func getConnectionInfoForModel(_ model: NodeTableCellModel) -> ConnectionInfo {
        let connectionInfo = ConnectionInfo.init(selectedMesh: meshDetailViewModel.mesh,
                                                 selectedMeshNode: model.device,
                                                 veeaHub: model.veeaHub,
                                                 isAvailableForConnection: model.isAvailableOnMas.data)

        return connectionInfo
    }

    func deviceModelForIndex(_ index: Int) -> ImageOptionView.ImageOptionViewModel {
        let models = nodeModelsForSearchTerm()
        let model = models[index]

        let name = model.device.formattedDeviceName
        let stateColor = stateColorForModel(model)
        let stateText = stateTextForModel(model)
        let locationImage = locationImageForModel(model)

        return ImageOptionView.ImageOptionViewModel(title: name,
                                                    image: locationImage,
                                                    subTitle: stateText,
                                                    indicatorColor: stateColor)
    }

    private func getHubInfoFor(model: NodeTableCellModel) -> HubInfo? {
        guard let hubInfo = meshDetailViewModel.hubInfo else {
            return nil
        }

        for info in hubInfo {
            if info.UnitSerial == model.id {
                return info
            }
        }

        return nil
    }

    private func nodeModelsForSearchTerm() -> [NodeTableCellModel] {
        if searchTerm.isEmpty {
            return meshDetailViewModel.cellViewModels
        }

        let filtered = meshDetailViewModel.cellViewModels.filter { nodeModel in
            let deviceLocatationName = nodeModel.device.formattedDeviceName
            return deviceLocatationName.lowercased().contains(searchTerm)
        }

        return filtered
    }

    private func stateColorForModel(_ model: NodeTableCellModel) -> UIColor {
        return model.healthState.data.color
    }

    private func stateTextForModel(_ model: NodeTableCellModel) -> String {
        if model.isPreparingFailed {
            return "Failed to add VeeaHub".localized()
        }
        else if model.isPreparing {
            return "Preparing for first use ..".localized()
        }

        // Otherwise return the health state
        return model.healthState.data.stateTitle
    }

    private func locationImageForModel(_ model: NodeTableCellModel) -> UIImage {
        guard let name = model.device.name else {
            return UIImage(named: "icon-error")!
        }

        return DefaultNodeDescriptionsAndImages.imageForTitle(name)
    }
}

extension ManageVeeaHubsViewModel: MeshDetailViewModelDelegate {
    func didUpdateMeshes(meshes: [VHMesh]) {
        delegate?.meshStateUpdated()
    }
}

// MARK: - Hub Mid Menu Optons
extension ManageVeeaHubsViewModel {
    func rebootHub(model: NodeTableCellModel, completion: @escaping (Bool, String) -> Void) {
        MasConnectionFactory.makeMasConectionFor(nodeSerial: model.id) { success, connection in
            if !success {
                completion(false, "Could not restart".localized())
                return
            }

            PowerCommands.restart(hub: connection) { success, message in
                if success {
                    completion(true, "Rebooting".localized())
                }
                else {
                    completion(false, "Could not restart".localized() + ": " + message)
                }
            }
        }
    }

    func aboutThisVeeahHub(cellModel: NodeTableCellModel, completion: @escaping(UIViewController?, String?) -> Void) {
        MasConnectionFactory.makeMasConectionFor(nodeSerial: cellModel.id) { success, connection in
            if !success {
                completion(nil, "Could not get a connection to the MAS")
            }

            if let connection = connection {
                ApiFactory.api.getMasApiIntermediaryModel(connection: connection) { model, error in
                    if let error = error {
                        completion(nil, "Error getting info from the MAS: \(error.localizedDescription)")
                        return
                    }

                    guard let model = model else {
                        completion(nil, "Error getting info from the MAS")
                        return
                    }

                    let vm = AboutVeeaHubViewModel(masModel: model,
                                                   hubInfo: self.getHubInfoFor(model: cellModel))
                    let vc = HostingController(rootView: AboutVeeaHubView(vm: vm))

                    completion(vc, nil)
                }
            }
            else {
                completion(nil, "Could not get a connection to the MAS")
            }
        }
    }

    func removeHub(model: NodeTableCellModel, completion: @escaping (Bool, String) -> Void) {
        let connectionInfo = getConnectionInfoForModel(model)
        let r = HubRemover.canHubBeRemoved(connectionInfo: getConnectionInfoForModel(model))
        if !r.0 {
            completion(false, r.1 ?? "No connection. Please check your internet connection.".localized())
        }

        HubRemover.remove(node: connectionInfo.selectedMeshNode) { (success, errorMessage) in
            WidgetCenter.shared.reloadAllTimelines()
            if success {
                completion(true, "")
                return
            }


            completion(false, errorMessage ?? "Please try again later".localized())
        }
    }
}
