//
//  GroupDisplayDetails.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 13/06/2023.
//

import Foundation

/// A limited set of info about a group that is true of all level of groups
public struct GroupDisplayDetails: Hashable, Identifiable {

    /// The idenfifiable value NOT the group Id!
    public var id = UUID()

    public let groupId: String
    public let groupName: String
    public var groupDescription: String {
        return subtitleText(group: groupModel)
    }

    public var pathIfFav: String? {
        if isFavSection { return readablePath }
        return nil
    }

    public let hasChildren: Bool
    public var isFavorite: Bool
    private var isFavSection: Bool // Is this being presented in the fav section

    public var groupModel: GroupModel



    public init(groupModel: GroupModel,
                isFav: Bool,
                isFavSection: Bool = false) {
        self.groupModel = groupModel
        self.groupId = groupModel.id
        self.groupName = groupModel.displayName
        self.hasChildren = groupModel.counts.children > 0
        self.isFavorite = isFav
        self.isFavSection = isFavSection
    }

    private func subtitleText(group: GroupModel) -> String {
        return "\(subtitleTextForSubGroups(group: group)). \(subtitleTextForMeshes(model: group))"
    }

    private func subtitleTextForSubGroups(group: GroupModel) -> String {
        let children = group.counts.children
        if children == 0 { return "No subgroups".localized() }
        else if children == 1 { return "1 subgroup".localized() }

        return "\(children) " + "subgroups".localized()
    }

    public var readablePath: String {
        let path = groupModel.path

        // First three items will be "root", self refistration and group name
        if path.count == 3 { return "Top Level Group".localized() }

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

    private func subtitleTextForMeshes(model: GroupModel) -> String {
        let meshes = model.counts.meshes
        var str = "\(meshes) " + "meshes".localized()

        if meshes == 0 { str = "No meshes".localized() }
        else if meshes == 1 { str = "1 mesh".localized() }

        return "\(str)."
    }

}
