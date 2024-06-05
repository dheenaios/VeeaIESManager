//
//  GroupSearchCoordinator.swift
//  IESManager
//
//  Created by Richard Stockdale on 02/08/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class GroupSearchCoordinator {

    private var timer: Timer? = nil
    private var searchTerm = ""
    private var childGroupId: String?


    /// Create a search service
    /// - Parameters:
    ///   - query: The search terms you are looking for
    ///   - childGroupId: An optional group id if searching within a child group. Nil for root groups
    func searchFor(searchTerm: String?,
                   childGroupId: String? = nil,
                   updated: @escaping ((GroupService?) -> Void)) {
        timer?.invalidate()

        guard let searchTerm else {
            updated(nil)
            return
        }

        if searchTerm.isEmpty {
            updated(nil)
            return
        }

        self.searchTerm = searchTerm
        self.childGroupId = childGroupId
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                          repeats: false,
                                          block: { timer in
            self.doSearch(updated: updated)
        })
    }

    private func doSearch(updated: @escaping((GroupService?) -> Void)) {
        let service = SearchGroupService(searchTerm: searchTerm,
                                         parentGroupId: childGroupId)

        updated(service)
    }
}
