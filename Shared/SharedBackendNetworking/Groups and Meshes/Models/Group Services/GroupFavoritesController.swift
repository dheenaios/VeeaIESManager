//
//  GroupFavoritesController.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 06/08/2023.
//

import Foundation

public protocol GroupFavoritesControllerUpdateDelegate {
    func updated()
    func errorUpdating(groupId: String, type: VKHTTPRequestCallType, errorData:ErrorHandlingData?, message: String)
}

public class GroupFavoritesController {

    var url = _GroupEndPoint("/enrollment/user/favoriteGroups")
    // e.g. https://dev.veeaplatform.net/enrollment/user/favoriteGroups

    public static var shared = GroupFavoritesController()
    public var updateDelegate: GroupFavoritesControllerUpdateDelegate?

    public private(set) var favorites = Set<GroupModel>()

    private var lastUpdate = Date()
    private let updateInterval: TimeInterval = 2 * 60 // Update every 2 mins


    public func isGroupFavorite(groupId: String) -> Bool {
        favorites.contains{ $0.id == groupId }
    }
    
    func updateFavGroupsBaseURL() {
        let endPointManager = EndPointConfigManager()
        let envType = endPointManager.currentConfig().type.rawValue
        print(envType)
        let config = endPointManager.getConfigFor(type: endPointManager.currentConfig().type)
        url = BackEndEnvironment.scheme+config.enrollmentEndpoint+"/enrollment/user/favoriteGroups"
    }


    /// Get the the currently favorited groups and updates the favorites array
    /// - Returns: The new set of favorites
    public func getFavoritedGroups() async {
        updateFavGroupsBaseURL()
        guard let groupIds = await getIds() else { return }
        guard let models = await getGroupModels(groupIds: groupIds) else { return }

        clearLocalFavorites()
        for model in models {
            favorites.insert(model)
        }

        await MainActor.run {
            lastUpdate = Date()
            updateDelegate?.updated()
        }
    }

    public func updateIfNeeded() {
        if favorites.isEmpty {
            Task { await getFavoritedGroups() }
        }
    }

    public func periodicUpdate() {
        Task { await self.getFavoritedGroups() }
    }

    /// Add or delete a favorite. Will return false if the max number has been reached
    public func updateFavorite(groupModel: GroupModel) -> Bool {
        updateFavGroupsBaseURL()
        if isGroupFavorite(groupId: groupModel.id) {
            deleteFavoritedGroup(groupModel: groupModel)
        }
        else {
            if maxFavsReached { return false }
            addGroupToFavorites(groupModel: groupModel)
        }

        return true
    }

    private var maxFavsReached: Bool {
        favorites.count > 9
    }

    /// Favorite group. Adds the favorited group to the favorites array and updates the backend
    private func addGroupToFavorites(groupModel: GroupModel) {
        favorites.insert(groupModel)
        Task {
            let success = await makeUpdateRequest(groupId: groupModel.id, type: .post)
            if !success.0 {
                favorites.remove(groupModel)
                let err = VKHTTPManagerError.parseError(error: success.2)
                await MainActor.run{ updateDelegate?.errorUpdating(groupId: groupModel.id, type: .post, errorData: success.1 ?? nil, message: err.description)}
            }
        }
    }

    /// Delete the favorited group from the favorites array and from the backend
    private func deleteFavoritedGroup(groupModel: GroupModel) {
        favorites.remove(groupModel)
        Task {
            let success = await makeUpdateRequest(groupId: groupModel.id, type: .delete)
            if !success.0 {
                await MainActor.run{
                    favorites.insert(groupModel) // Add the group model back
                    let err = VKHTTPManagerError.parseError(error: success.2)
                    updateDelegate?.errorUpdating(groupId: groupModel.id, type: .delete,  errorData: success.1 ?? nil, message: err.description)}
            }
        }
    }

    public func clearLocalFavorites() {
        favorites = Set<GroupModel>()
    }
}


// MARK: - Networking calls

extension GroupFavoritesController {
    private func getIds() async -> [String]? {
        do {
            let request = try VKHTTPRequest.create(url: url, type: .get)

            let response = try await VKHTTPManager.call(request: request, requireResponseKey: false)
            guard let favs = VKDecoder.decode(type: FavoriteResponse.self, data: response.1) else {
                SharedLogger.log(tag: "GroupService", message: "Error decoding child group info... 0")
                return nil
            }

            return favs.response.map { item in item.groupId }
        }
        catch let e {
            SharedLogger.log(tag: "GroupService", message: "Error decoding group info.. 1 - \(e)")
            return nil
        }
    }


    private func makeUpdateRequest(groupId: String, type: VKHTTPRequestCallType) async -> (Bool, ErrorHandlingData?, Error?) {
        do {
            let formattedUrl = type == .delete ? (url + "/\(groupId)") : url
            let request = try VKHTTPRequest.create(url: formattedUrl, type: type, data: bodyData(groupId: groupId))
            let result = try await VKHTTPManager.call(request: request, requireResponseKey: false)
            if !result.0 {
                if let data = result.1 {
                    SharedLogger.log(tag: "GroupService", message: "Call failed with: \(data.prettyPrintedString ?? "?")")
                }
                else {
                    SharedLogger.log(tag: "GroupService", message: "Call failed, no data")
                }
            }
            if let errorData = result.3 {
                return (result.0,errorData,result.2)
            }
            else {
                return (result.0, nil, result.2)
            }
        }
        catch let e {
            SharedLogger.log(tag: "GroupFavoritesController", message: "Error decoding fav update request response - \(e)")
        }

        return (false, nil, nil)
    }

    private func getGroupModels(groupIds: [String]) async -> [GroupModel]? {
        return await GroupService.getGroupsFor(groupIds: groupIds)
    }

    private func bodyData(groupId: String) -> Data? {
        let dic = ["groupId" : groupId]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            return jsonData
        }
        catch let e {
            SharedLogger.log(tag: "GroupFavoritesController", message: "Error encoding group info.. 2 - \(e)")
        }

        return nil
    }
}

// MARK: - Models
private struct FavoriteResponse: Codable {
    let meta: ResponseMeta
    let response: [FavoriteDetails]
}

private struct FavoriteDetails: Codable {
    let groupId: String
    let groupDisplayName: String
    let ownerEmail: String
}
