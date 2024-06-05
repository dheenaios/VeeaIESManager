//
//  MeshesViewModel.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/25/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import UIKit
import SharedBackendNetworking

final class MeshSelectionViewModel: NSObject {
    
    var lastDataLoad: Date?
    var hasViewVanishedSinceLastUpdate = false
    
    private(set) var availableMeshes: [VHMesh] = []

    //private(set) var groupVM : GroupsViewModel // TODO: Is this needed now?

    private(set) var userGroupsService: UserGroupService

    var selectedGroup: GroupDetailsModel {
        let details = GroupDetailsModel(groupModel: GroupModel.selectedModel!)
        return details
    }

    var searchTerm = ""
    
    var isLoading = Observable<Bool>(false)
    var errorOccured = Observable<String>("")
    var showTableContent = Observable<Bool>(true)
    var showNodeviceView = Observable<Bool>(false)
    var showMeshDetailsForNotification = Observable<Bool>(false)
    
    var dnsLookUp : DnsLookupManager!

    private var filteredMeshes: [VHMesh] {
        if searchTerm.isEmpty {
            return availableMeshes
        }
        
        let filtered = availableMeshes.filter {
            $0.name.lowercased().contains(searchTerm)
        }
        //print("Filtered count = \(filtered.count)")
        return filtered
    }
    
    init(groupService: UserGroupService,
         selectedGroup: GroupDetailsModel,
         dispatchImmediately : Bool = true) {
        GroupModel.selectedModel = selectedGroup.groupData

        self.dnsLookUp = DnsLookupManager(groupId: selectedGroup.groupId)
        self.userGroupsService = groupService
        super.init()
        if dispatchImmediately {
            //self.dispatchDataFetcher()
        }
    }


    /// Load the selected group. Or the group with the passed in id
    /// - Parameter id: An optional id. If nothing is passed then the selected group is loaded
    func loadGroupConfigForCurrentGroup(id: String? = nil) {
        if let id {
            self.loadGroupConfig(groupId: id)
            return
        }

        self.loadGroupConfig(groupId: GroupModel.selectedModel!.id)
    }
    
    func loadGroupConfig(groupId : String) {
        lastDataLoad = Date()
        
        self.isLoading.data = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            EnrollmentService.getOwnerConfig(groupId: groupId, success: { [weak self] (meshes) in
                if let m = meshes {
                    let sortedMeshes = m.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                    self?.availableMeshes = sortedMeshes
                }
                
                self?.updateDisplayLogic()
                self?.errorOccured.data = ""
                self?.isLoading.data = false
            }) { [weak self] (err) in
                // Handle error
                if !((self?.availableMeshes.count ?? 0) > 0) {
                    self?.showNodeviceView.data = false
                    self?.showTableContent.data = false
                    self?.errorOccured.data = err
                }
                //VKLog(err)
                self?.isLoading.data = false
            }
        }
    }
    
    func loadGroupConfigForHandlingPush(groupId : String) {
        lastDataLoad = Date()
        
        self.isLoading.data = true
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            EnrollmentService.getOwnerConfig(groupId: groupId, success: { [weak self] (meshes) in
                self?.showMeshDetailsForNotification.data = true
                if let m = meshes {
                    let sortedMeshes = m.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                    self?.availableMeshes = sortedMeshes
                }
               
                self?.updateDisplayLogic()
                self?.errorOccured.data = ""
                self?.isLoading.data = false
              
            }) { [weak self] (err) in
                // Handle error
                if !((self?.availableMeshes.count ?? 0) > 0) {
                    self?.showNodeviceView.data = false
                    self?.showTableContent.data = false
                    self?.showMeshDetailsForNotification.data = false
                    self?.errorOccured.data = err
                }
                //VKLog(err)
                self?.isLoading.data = false
            }
        }
    }
    
    func updateDisplayLogic() {
        self.showTableContent.data = (self.availableMeshes.count > 0)
        self.showNodeviceView.data = !(self.availableMeshes.count > 0)
    }
    
    func getViewMeshModels() -> [VUITableCellModelProtocol] {
        var vms = [VUITableCellModelProtocol]()
        for item in filteredMeshes {
            vms.append(MeshCellViewModel(meshData: item))
        }
        
        return vms
    }
    
    func getAvailableMeshes() -> [VHMesh] {
        return availableMeshes
    }
    
    func viewToShow(for indexPath: IndexPath) -> UIViewController {
        let vc = UIStoryboard(name: "GroupMeshSelection", bundle: nil)
            .instantiateViewController(withIdentifier: "MeshDetailViewController") as! MeshDetailViewController
        
        let meshDetailVM = MeshDetailViewModel(groupId : self.selectedGroup.groupId,
                                               meshes: availableMeshes,
                                               selectedPosition: getSelectedPosition(indexPath: indexPath),
                                               delegate: self)
        meshDetailVM.dnsLookUp = dnsLookUp
        vc.setViewModel(viewModel: meshDetailVM)
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
    
    
    /// Works out the position of the selected item in the meshes list (rather than the fildered list
    /// - Parameter indexPath: selected index path
    /// - Returns: The position
    private func getSelectedPosition(indexPath: IndexPath) -> Int {
        if searchTerm.isEmpty {
            return indexPath.row
        }
        
        let selectedModel = filteredMeshes[indexPath.row]
        
        for (index, mesh) in availableMeshes.enumerated() {
            if selectedModel.id == mesh.id {
                return index
            }
        }
        
        // If we get here something has gone wrong
        return indexPath.row
    }
    
    private func dispatchDataFetcher() {
        self.loadGroupConfigForCurrentGroup()
    }
}

extension MeshSelectionViewModel: MeshDetailViewModelDelegate {
    func didUpdateMeshes(meshes: [VHMesh]) {
        self.availableMeshes = meshes
    }

    func shouldUpdateGroups() {
        loadGroupConfigForCurrentGroup()
    }
}

extension MeshSelectionViewModel: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //print("updatedResults")
    }
}


//MARK: - IESScannerDelegate
extension MeshSelectionViewModel: HubBeaconScannerDelegate {
    
    func didFindIes(_ device: VeeaHubConnection) {
    }
    
    func didUpdateIes(_ device: VeeaHubConnection) {
    }
    
    func didLooseIes(_ device: VeeaHubConnection) {
    }
}
