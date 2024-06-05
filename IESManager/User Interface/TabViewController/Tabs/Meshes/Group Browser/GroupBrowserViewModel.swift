//
//  GroupBrowserViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 14/06/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class GroupBrowserViewModel: ObservableObject {
    private var groupService: GroupService
    private var searchGroupService: GroupService?
    private var groupFavoritesController = GroupFavoritesController.shared

    var isSearching: Bool { searchGroupService != nil }

    @Published var isLoading = false
    var selectedSegment :Int = 0
    var searchText : String = ""

    @Published var groupDisplayDetails: [GroupDisplayDetails]
    @Published var favoriteGroupDisplayDetails: [GroupDisplayDetails]
    @Published var showFavError: Bool = false
    @Published var errorData: ErrorHandlingData?
    @Published var isFavUpdated: Bool = false
    var favErrorText: String = ""

    @UserDefaultsBacked(key: "showFavs", defaultValue: true)
        var showFavs: Bool

    private lazy var searchCoord: GroupSearchCoordinator = {
        return GroupSearchCoordinator()
    }()

    var breadcrumbs: String? {
        groupService.readablePath
    }

    func switchToGroup(selectedGroup: String) -> GroupModel? {
        let groups = isSearching ? searchGroupService!.groupModels : groupService.groupModels
        if let group = groups.first(where: { $0.id == selectedGroup }) {
            GroupModel.selectedModel = group
            return group
        }

        // Find from the favorites
        if let group = groupFavoritesController.favorites.first(where: { $0.id == selectedGroup }) {
            GroupModel.selectedModel = group
            return group
        }

        return nil
    }

    func toggleFavorite(model: GroupDisplayDetails) {
        let success = groupFavoritesController.updateFavorite(groupModel: model.groupModel)
        if !success {
            // TODO: Display the message from the backend response.
            favErrorText = "Unable to mark favorite group as favorite because the user has reached to the max limit for groups: 10".localized()
            showFavError.toggle()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateGroupDisplayDetails()
        }
    }

    func refreshDataIfNeeded() {
        groupFavoritesController.updateDelegate = self
        groupFavoritesController.periodicUpdate()
        if groupService.isDataStale {
            Task { await groupService.loadGroup() }
        }
    }
    
    func refreshFavDataIfNeeded() {
        groupFavoritesController.updateDelegate = self
        groupFavoritesController.periodicUpdate()
    }

    /// The one and only place to update group display details
    func updateGroupDisplayDetails() {
        var details = [GroupDisplayDetails]()
        var favs = [GroupDisplayDetails]()

        let groups = isSearching ? searchGroupService!.groupModels : groupService.groupModels

        for group in groups {
            let isFav = groupFavoritesController.isGroupFavorite(groupId: group.id)
            let detail = GroupDisplayDetails(groupModel: group,
                                             isFav: isFav)

            details.append(detail)
        }

        for fav in groupFavoritesController.favorites {
            let detail = GroupDisplayDetails(groupModel: fav,
                                             isFav: true,
                                             isFavSection: true)
            favs.append(detail)
        }

        groupDisplayDetails = details
        favoriteGroupDisplayDetails = favs
        if self.selectedSegment == 1 {
            if searchText != "" {
                let favResultAfterSearch = favs.filter{$0.groupName.localizedCaseInsensitiveContains(self.searchText.lowercased())}
                 favoriteGroupDisplayDetails = favResultAfterSearch
            }else{
                favoriteGroupDisplayDetails = favs
            }
        }
    }

    internal init(groupService: GroupService) {
        self.groupDisplayDetails = [GroupDisplayDetails]()
        self.favoriteGroupDisplayDetails = [GroupDisplayDetails]()
        self.groupService = groupService
        self.groupService.delegate = self
        self.updateGroupDisplayDetails()
    }
}

// MARK: - Search
extension GroupBrowserViewModel {
    func searchQueryChanged(searchTerm: String?,selectedSegment:Int) {
        guard let searchTerm else {
            stopSearching()
            return
        }
        
        if searchTerm.isEmpty {
            stopSearching()
            return
        }
        
        self.searchText = searchTerm
        self.selectedSegment = selectedSegment
        if selectedSegment == 0 {
            var childGroupId: String? = nil
            if let childGroupService = groupService as? ChildGroupService {
                childGroupId = childGroupService.groupId
            }
            
            self.searchCoord.searchFor(searchTerm: searchTerm,
                                       childGroupId: childGroupId) { searchGroupService in
                self.searchGroupService = searchGroupService
                self.searchGroupService?.delegate = self
            }
        }
        
        updateGroupDisplayDetails()
    }

     func stopSearching() {
        searchText = ""
        searchGroupService = nil
        self.updateGroupDisplayDetails()
    }
}

extension GroupBrowserViewModel: GroupServiceDelegate {
    func noMoreGroupsToLoad(groupService: SharedBackendNetworking.GroupService) {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    func groupServiceDidUpdate(groupService: SharedBackendNetworking.GroupService) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.updateGroupDisplayDetails()
        }
    }
}

extension GroupBrowserViewModel: PageableItemsProtocol {

    func threshold() -> Int { return 2 }

    func isLoadThresholdItem(identifiableItem: any Identifiable) {
        let index = groupDisplayDetails.firstIndex { model in
            model.id == identifiableItem.id as! UUID
        }

        if isThresholdItem(itemIndex: index, modelsCount: groupService.groupModels.count) {
            isLoading = true
            Task {
                await groupService.loadGroup(next: true)
            }
        }
    }
}

extension GroupBrowserViewModel: GroupFavoritesControllerUpdateDelegate {
    func errorUpdating(groupId: String, type: SharedBackendNetworking.VKHTTPRequestCallType, errorData:ErrorHandlingData?, message: String) {

//        var message = ""
//        if type == .delete { // Was not able to delete
//            message = "Could not delete group from favorites"
//        }
//        else { // Was not able to post
//            message = "Could not add group to favorites"
//        }
        
        favErrorText = message
        //self.errorData = errorData
        showFavError.toggle()
        refreshFavDataIfNeeded()
        updateGroupDisplayDetails()
    }

    func updated() {
        updateGroupDisplayDetails()
    }
}
