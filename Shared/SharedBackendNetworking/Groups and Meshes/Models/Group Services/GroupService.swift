//
//  GroupService.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 16/06/2022.
//

import Foundation

fileprivate enum GroupEndpoints {

    private var limit: Int { 50 }

    /// Associated values for the user group and an optional for the cursor.
    case userGroupDetails(String, String? = nil)

    /// Associated values for the user group and an optional for the cursor.
    case childGroupDetails(String, String? = nil)

    /// Associated values for the search term, userId and an optional for the cursor.
    case searchUserGroupDetails(String, String? = nil)

    /// Associated values for the search term, the parent group and an optional for the cursor.
    case searchChildGroupDetails(String, String, String? = nil)

    var value: String {
        var path = ""
        switch self {
        case .userGroupDetails(let userId, let nextCursor):
            if let nextCursor {
                path = "/groupservice/api/v2/users/\(userId)/groups?&next=\(nextCursor)&limit=\(limit)&parentsOnly=true"
            }
            else {
                path = "/groupservice/api/v2/users/\(userId)/groups?limit=\(limit)&parentsOnly=true"
            }
        case .childGroupDetails(let groupIds, let nextCursor):
            if let nextCursor {
                path = "/groupservice/api/v2/groups/\(groupIds)/children?next=\(nextCursor)&limit=\(limit)"
                // e.g. v2/groups/cdaf1bd3-bd00-46f6-b599-a81b45ea5777/children?next=132131232&limit=50
            }
            else {
                path = "/groupservice/api/v2/groups/\(groupIds)/children?limit=\(limit)"
                // e.g. v2/groups/cdaf1bd3-bd00-46f6-b599-a81b45ea5777/children?limit=50
            }
        case .searchUserGroupDetails(let searchTerm, let nextCursor):
            if let nextCursor {
                path = "/groupservice/api/v2/groups?searchDisplayName=\(searchTerm)&next=\(nextCursor)&limit=\(limit)" // TODO: Need to test
            }
            else {
                path = "/groupservice/api/v2/groups?searchDisplayName=\(searchTerm)&limit=\(limit)"
                // groupservice/api/v2/groups?searchDisplayName=rajat
            }
        case .searchChildGroupDetails(let searchTerm, let parentGroup, let nextCursor):
            if let nextCursor {
                path = "/groupservice/api/v2/groups/\(parentGroup)/children?limit=\(limit)&searchDisplayName=\(searchTerm)&next=\(nextCursor)" // TODO: Need to test
            }
            else {
                path = "/groupservice/api/v2/groups/\(parentGroup)/children?limit=\(limit)&searchDisplayName=\(searchTerm)"
                // groupservice/api/v2/groups/f781cd02-01b5-47d6-8ce3-4ccc4426acdf/children?limit=10&searchDisplayName=rajat
            }
        }

        return _GroupEndPoint(path)
    }
}

public protocol GroupServiceDelegate {
    func groupServiceDidUpdate(groupService: GroupService)
    func noMoreGroupsToLoad(groupService: GroupService)
}

/// Base Class used for querying users groups.
/// Use the static methods directly or Init one of the class to make use of pagination
public class GroupService {
    public var groupModels = [GroupModel]()
    var lastMeta = Meta(nextCursor: nil, prevCursor: nil)
    public var delegate: GroupServiceDelegate?


    private let dataExpirationInSeconds: Double = 360

    /// Use this the set this to keep a record of the freshness of the data
    var lastInitialLoadTime: Date?

    /// Is the data old. If it is, reload
    /// Returns false if no initial load time is set
    public var isDataStale: Bool {
        guard let lastInitialLoadTime else { return true }
        let expirationTime = lastInitialLoadTime.addingTimeInterval(dataExpirationInSeconds)
        let stale = Date() > expirationTime

        return stale
    }


    /// Are there more items to load
    public var moreAvailable: Bool {
        get {
            guard let nextCursor = lastMeta.nextCursor else { return false }
            return !nextCursor.isEmpty
        }
    }

    public var readablePath: String? {
        guard let path = groupModels.first?.path else { return nil }

        // First three items will be "root", self refistration and group name
        if path.count == 3 { return nil }

        var pathStr = ""
        for item in path {
            // Do not add the non user paths
            if item.displayName == "root" || item.displayName == "SelfRegistration" { continue }
            pathStr.append(item.displayName)
            pathStr.append(" > ")
        }

        // Remove last /
        return String(pathStr.dropLast(3))
    }

    public func loadGroup(next: Bool = false) async { fatalError("Must Override") }

    // Prevent direct init of the Group Service. Init one of its subclasses
    init() {}
}

// MARK: - Static Methods for calling backend
extension GroupService {

    // MARK: - Top Level Groups

    // 4 May 2023 - VHM 1608: Updated to new API. This returns the same models as ChildGroupResponse
    public class func getGroupDetailsForCurrentUser(nextCursor: String? = nil) async -> [GroupModel] {
        let response = await getGroupsForCurrentUser(nextCursor: nextCursor)
        return response?.data ?? [GroupModel]()
    }

    public class func getGroupDetailsForCurrentUser(nextCursor: String? = nil, success: @escaping (_ groups: [GroupModel]) -> Void,
                                                error: @escaping ErrorCallback) {
        Task {
            let groups = await getGroupDetailsForCurrentUser(nextCursor: nextCursor)
            DispatchQueue.main.async {
                success(groups)
            }
        }
    }

    // MARK: - User and Child group responses
    public class func getGroupsForCurrentUser(nextCursor: String? = nil) async -> GroupResponse? {
        guard let sub = AuthorisationManager.shared.userId else { return nil }
        let url = GroupEndpoints.userGroupDetails(sub,
                                                  nextCursor).value

        return await makeGroupsCall(url: url)
    }

    public class func getChildrenGroupsForCurrentUser(groupId: String,
                                                      nextCursor: String? = nil) async -> GroupResponse? {
        let url = GroupEndpoints.childGroupDetails(groupId,
                                                   nextCursor).value
        let response = await makeGroupsCall(url: url)
        return response
    }

    // MARK: - Search
    public class func searchGroupsForCurrentUser(searchTerm: String,
                                                 nextCursor: String? = nil) async -> GroupResponse? {
        let url = GroupEndpoints.searchUserGroupDetails(searchTerm,
                                                        nextCursor).value

        return await makeGroupsCall(url: url)

    }

    public class func searchChildGroupsForCurrentUser(searchTerm: String,
                                                      groupId: String,
                                                      nextCursor: String? = nil) async -> GroupResponse? {
        let url = GroupEndpoints.searchChildGroupDetails(searchTerm,
                                                         groupId,
                                                         nextCursor).value

        return await makeGroupsCall(url: url)
    }

    public class func getGroupsFor(groupIds: [String]) async -> [GroupModel]? {
        let groups = groupIds.joined(separator: "%2C")

        let path = "/groupservice/api/v2/groups/\(groups)"
        let url = _GroupEndPoint(path)
        guard let response = await getResponse(url: url) else {
            SharedLogger.log(tag: "GroupService", message: "Error getting requested groups")
            return nil
        }

        guard let models = VKDecoder.decode(type: [GroupModel].self, data: response.1) else {
            SharedLogger.log(tag: "GroupService", message: "Error decoding group models")
            return nil
        }

        return models
    }

    // MARK: - Send
    private static func makeGroupsCall(url: String) async -> GroupResponse? {
        guard let response = await getResponse(url: url) else {
            return nil
        }

        guard let childGroupResponse = VKDecoder.decode(type: GroupResponse.self, data: response.1) else {
            SharedLogger.log(tag: "GroupService", message: "Error decoding child group info... 0")
            return nil
        }

        return childGroupResponse
    }

    private static func getResponse(url: String) async -> (Bool, Data?, Error?, ErrorHandlingData?)? {
        do {
            let request = try VKHTTPRequest.create(url: url)
            return try await VKHTTPManager.call(request: request, requireResponseKey: false)
        }
        catch let e {
            SharedLogger.log(tag: "GroupService", message: "Error getting response - \(e)")
            return nil
        }

    }
}
