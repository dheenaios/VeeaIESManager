//
//  DashboardItemKeys.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 07/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

// MARK: - JSON Object Keys
struct ItemKeys {
    static let itemIDKey = "itemID"
    static let iosSegueIDKey = "iosSegueID"
    static let isEnabledKey = "isEnabled"
    static let isHiddenKey = "isHidden"
    static let iosIconNameKey = "iosIconName"
    static let titleKey = "title"
    static let subTitleKey = "subTitle"
    static let isOptionalKey = "isOptional"
}

// MARK: - Dashboard Item Leys
struct DashboardItemKeys {
    static let nodeItem = "nodeItem"
    static let vMeshItem = "meshGatewayItem"
    static let beaconItem = "beaconItem"
    static let gatewayItem = "gatewayItem"
    static let meshGatewayItem = "meshGatewayItem"
    static let databaseItem = "Database"
    static let displayItem = "Display"
    static let physicalAp1 = "twoGhzAp"
    static let physicalAp2 = "fiveGhzAp"
    static let wanNode = "wanNode"
    static let routerItem = "routerItem"
    static let firewallItem = "firewallItem"
    static let mediaItem = "media_analytics"
    static let retailItem = "retail_analytics"
    static let cellularStatsItem = "cellularStatsItem"
    static let wifiStatsItem = "wifiStatsItem"
    static let iPItem = "iPItem"
    static let serversItem = "serversItem"
    static let powerItem = "powerItem"
    static let appFolder = "appFolder"
    static let physicalPorts = "physicalPorts"
    static let vlan = "vlan"
    static let optionalServices = "optional_services"
    static let sdWan = "sdWan"
    static let lanConfig = "lanConfig"
}

// MARK: - Services Item Leys
struct ServicesItemKeys {
    static let sdWanCellularStats = "sd_wan"
    static let publicWifi = "public_wifi"
}
