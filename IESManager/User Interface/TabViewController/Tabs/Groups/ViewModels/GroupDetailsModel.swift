//
//  GroupDetailsViewModel.swift
//  VeeaHub Manager
//
//  Created by Bajirao Bhosale on 11/05/21.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class GroupDetailsModel {
    
    var groupData : GroupModel!
    var hasMultipleGroups : Bool = false


    init(groupModel: GroupModel, hasMultiGroups : Bool = false) {
        self.groupData = groupModel
        self.hasMultipleGroups = hasMultiGroups
    }

//    init(groupModel : GroupsModel, hasMultiGroups : Bool = false) {
//        self.groupData = groupModel
//        self.hasMultipleGroups = hasMultiGroups
//    }
    
    var groupId : String {
        return groupData.id
    }
    
    var groupName : String {
        return groupData.name
    }
    
    var groupDisplayName : String {
        return groupData.displayName
    }
    
    var hasMeshes : Bool {
        return self.groupData.counts.meshes > 0
    }

    
}
