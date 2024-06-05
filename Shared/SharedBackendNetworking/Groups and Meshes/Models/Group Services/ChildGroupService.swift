//
//  ChildGroupService.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 12/06/2023.
//

import Foundation

public class ChildGroupService: GroupService {

    public let groupId: String

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
        guard let groupResponse = await GroupService.getChildrenGroupsForCurrentUser(groupId: groupId) else {
            return
        }

        self.groupModels = groupResponse.data
        self.lastMeta = groupResponse.meta
        self.delegate?.groupServiceDidUpdate(groupService: self)
    }

    public func startInitialLoad() {
        Task {
            await self.loadGroup()
        }
    }

    private func getNextPage(nextCursor: String) async {
        guard let groupResponse = await UserGroupService.getChildrenGroupsForCurrentUser(groupId: groupId,
                                                                                         nextCursor: nextCursor) else {
            delegate?.noMoreGroupsToLoad(groupService: self)
            return
        }

        self.groupModels.append(contentsOf: groupResponse.data)
        self.lastMeta = groupResponse.meta
        self.delegate?.groupServiceDidUpdate(groupService: self)
    }

    public init(groupId: String) {
        self.groupId = groupId
        super.init()
    }
}
