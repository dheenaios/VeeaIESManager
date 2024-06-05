//
//  UserGroupService.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 12/06/2023.
//

import Foundation

public class UserGroupService: GroupService {

    public override func loadGroup(next: Bool = false) async {
        if !moreAvailable && next {
            delegate?.noMoreGroupsToLoad(groupService: self)
            return
        }

        if next {
            guard let nextCursor = lastMeta.nextCursor else { return }
            await getNextPage(nextCursor: nextCursor)
            return
        }

        // Load from the first position
        lastInitialLoadTime = Date()
        guard let groupResponse = await GroupService.getGroupsForCurrentUser() else {
            return
        }
        self.groupModels = groupResponse.data
        self.lastMeta = groupResponse.meta
        self.delegate?.groupServiceDidUpdate(groupService: self)
    }

    private func getNextPage(nextCursor: String) async {
        guard let groupResponse = await UserGroupService.getGroupsForCurrentUser(nextCursor: nextCursor) else {
            return
        }

        self.groupModels.append(contentsOf: groupResponse.data)
        self.lastMeta = groupResponse.meta
        self.delegate?.groupServiceDidUpdate(groupService: self)
    }

    public override init() {
        super.init()
        Task { await loadGroup() }
    }
}
