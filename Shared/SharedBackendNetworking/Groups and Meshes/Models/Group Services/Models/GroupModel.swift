//
//  ChildGroupModel.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 18/04/2023.
//

import Foundation

public struct GroupModel: Codable, Equatable, Identifiable, Hashable {
    private static let kSelectedGroup = "kSelectedGroup"

    public static func == (lhs: GroupModel, rhs: GroupModel) -> Bool {
        return lhs.counts == rhs.counts &&
        lhs.displayName == rhs.displayName &&
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.path == rhs.path
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let counts: Counts
    public let displayName: String
    public let id: String
    public let name: String
    public let path: [PathElement]

    public var parentGroupId: String? {
        if path.count < 2 { return nil }
        return path[path.count - 2].id
    }

    init(counts: Counts, displayName: String, id: String, name: String, path: [PathElement]) {
        self.counts = counts
        self.displayName = displayName
        self.id = id
        self.name = name
        self.path = path
    }
}

public struct Counts: Codable, Equatable {
    public let children: Int
    public let devices: Int
    //public let listeners: Int // Not used
    public let meshes: Int
    public let users: Int
}

public struct PathElement: Codable, Equatable {
    public let displayName: String
    public let id: String
    public let name: String
}

public struct GroupResponse: Codable {
    public let data: [GroupModel]
    let meta: Meta
}

public struct Meta: Codable {
    let nextCursor: String?
    let prevCursor: String?
}

// MARK: - Selected Model
extension GroupModel {
    public static var selectedModel: GroupModel? {
        get {
            let defaults = UserDefaults.standard
            if let savedData = defaults.object(forKey: kSelectedGroup) as? Data {
                let decoder = JSONDecoder()
                if let loadedGroup = try? decoder.decode(GroupModel.self, from: savedData) {
                    return loadedGroup
                }
            }

            return nil
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: kSelectedGroup)
            }
        }
    }
}
