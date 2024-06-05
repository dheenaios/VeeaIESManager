//
//  NSNotificationExtensions.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 04/07/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

extension NSNotification {
    static func notifyOfConfigChange(config: ApiRequestConfigProtocol) {
        NotificationCenter.default.post(name: NSNotification.Name.userDidUpdateConfig,
                                        object: config)
    }
}

extension NSNotification.Name {
    static let HotspotConfigCompleted = Notification.Name("HotspotConfigCompleted")
    static let DataModelUpdateCompleted = Notification.Name("DataModelUpdateCompleted")
    static let AppHeartBeat = Notification.Name("AppHeartBeat")
    static let TokenUpdated = Notification.Name("TokenUpdatedNotification")
    static let logoutNotification = Notification.Name("LogoutNotification")
    static let updateMeshes = Notification.Name("UpdateMeshes")
    static let userDidUpdateConfig = Notification.Name("userDidUpdateConfig")
    static let NetworkStateDidChange = Notification.Name("networkStateDidChange")
}
