//
//  SearchUserGroupService.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 03/08/2023.
//

import Foundation


/// Create a new instance for each search that is sent to the backend
/// This service will then handle pagination for the results
public class SearchGroupService: GroupService {

    let searchTerm: String
    private var parentGroupId: String?


    public override func loadGroup(next: Bool = false) async {
        if !moreAvailable && next {
            delegate?.noMoreGroupsToLoad(groupService: self)
            return
        }

        if next {
            guard let nextCursor = lastMeta.nextCursor else { return }
            await doLoad(nextCursor: nextCursor)
            return
        }

        // Load from the first position
        lastInitialLoadTime = Date()
        await doLoad()
    }

    private func doLoad(nextCursor: String? = nil) async {
        if let parentGroupId {
            guard let groupResponse = await GroupService
                .searchChildGroupsForCurrentUser(searchTerm: searchTerm,
                                                 groupId: parentGroupId, nextCursor: nextCursor) else {
                return
            }

            update(response: groupResponse)
        }
        else {
            guard let groupResponse = await GroupService
                .searchGroupsForCurrentUser(searchTerm: searchTerm) else {
                return
            }

            update(response: groupResponse)
        }
    }

    private func update(response: GroupResponse) {
        self.groupModels = response.data
        self.lastMeta = response.meta
        self.delegate?.groupServiceDidUpdate(groupService: self)
    }


    /// Creates a new SearchGroupService to handle a search and pagination of that search
    /// - Parameters:
    ///   - searchTerm: The search term to be searched for
    ///   - parentGroupId: The parent group to be searched under.
    ///   Nil if we are searching from the top level.
    public init(searchTerm: String,
                parentGroupId: String? = nil) {
        self.searchTerm = searchTerm
        self.parentGroupId = parentGroupId
        super.init()
        Task { await loadGroup() }
    }
}
