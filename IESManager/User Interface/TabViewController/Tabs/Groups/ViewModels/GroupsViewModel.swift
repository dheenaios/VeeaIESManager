//
//  GroupsViewModel.swift
//  VeeaHub Manager
//
//  Created by Bajirao Bhosale on 11/05/21.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit
import SharedBackendNetworking


class GroupsViewModel: NSObject {

    var groups : [GroupModel]?

    var numberOfGroups : Int {
        return self.groups?.count ?? 0
    }
    
    func getGroupDetailsViewModel(for indexPath: IndexPath) -> GroupDetailsModel {
        return GroupDetailsModel(groupModel: self.groups![indexPath.row], hasMultiGroups: self.groups!.count > 1)
    }
    
    func loadGroups(success : @escaping () -> (), error : @escaping (String) -> ()) {
        GroupService.getGroupDetailsForCurrentUser { groups in
            if groups.isEmpty {
                error("Account has no user groups.")
                return
            }

            self.groups = groups
            success()
        } error: { errorMsg in
            error(errorMsg)
        }
    }
}
