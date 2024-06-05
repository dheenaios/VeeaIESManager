//
//  OptionsManager.swift
//  HealthWidgetIntentHandler
//
//  Created by Richard Stockdale on 15/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

public struct DeviceOptionsManager {

    private static let saveDevicesKey = "kSavedDevicesKey"

    public func getDevices(completion: @escaping([NodeModel], String?) -> Void) {
        // Refresh the user details, as the user may have done many things in the main
        // app that has made this instance out of date
        Task {
            await UserSessionManager.shared.loadUser()
            await MainActor.run {
                loadMeshes(completion: completion)
            }
        }
    }

    private func loadMeshes(completion: @escaping([NodeModel], String?) -> Void) {
        GroupService.getGroupDetailsForCurrentUser { groups in
            guard let groupId = groups.first?.id else { return }
            MeshService.getDevicesForSoleMesh(groupId: groupId) { devices, error in
                if let error = error {
                    completion([NodeModel](), error)
                    return
                }
                guard let devices = devices else { return }
                saveDeviceDetails(nodes: devices)
                completion(devices, error)
                return
            } error: { message in
                completion([NodeModel](), "Mesh Load Result: \(message)")
            }


        } error: { errorMsg in
            //print(errorMsg)
            completion([NodeModel](), "Mesh Load Call: \(errorMsg)")
        }
    }

    public static func allHubIdsStillValid(widgetHubIds: [String]) -> Bool {
        for widgetHubId in widgetHubIds {
            if !DeviceOptionsManager.hubIdPresent(hubId: widgetHubId) {
                return false
            }
        }

        return true
    }

    public static func hubIdPresent(hubId: String) -> Bool {
        let nodes = DeviceOptionsManager.cachedDeviceDetails
        for node in nodes {
            if node.id == hubId {
                return true
            }
        }

        return false
    }

    private func saveDeviceDetails(nodes: [NodeModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(nodes) {
            SharedUserDefaults.suite.set(encoded, forKey: DeviceOptionsManager.saveDevicesKey)
        }
    }

    public static var cachedDeviceDetails: [NodeModel] {
        guard let deviceData = SharedUserDefaults.suite.data(forKey: DeviceOptionsManager.saveDevicesKey),
              let devices = try? JSONDecoder().decode([NodeModel].self, from: deviceData) else {
            return [NodeModel]()
        }

        return devices
    }

    public static var getCachedMen: NodeModel? {
        let cachedDevices = cachedDeviceDetails
        for device in cachedDevices {
            if let isMen = device.isMEN {
                if isMen { return device}
            }
        }

        return nil
    }

    public static func deleteCachedDeviceDetails() {
        SharedUserDefaults.suite.removeObject(forKey: DeviceOptionsManager.saveDevicesKey)
    }

    public init(){}
}
