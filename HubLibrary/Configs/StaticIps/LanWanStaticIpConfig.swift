//
//  LanWanStaticIpConfig.swift
//  IESManager
//
//  Created by Richard Stockdale on 31/03/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

public struct LanWanStaticIpConfig: Equatable, Codable {

    public static func == (lhs: LanWanStaticIpConfig, rhs: LanWanStaticIpConfig) -> Bool {
        let same = lhs.use == rhs.use &&
            lhs.ip4_address == rhs.ip4_address &&
            lhs.ip4_gateway == rhs.ip4_gateway &&
            lhs.ip4_dns_1 == rhs.ip4_dns_1 &&
            lhs.ip4_dns_2 == rhs.ip4_dns_2

        return same
    }

    private var originalJson: JSON = JSON()

    public var use: Bool
    public var ip4_address: String // AKA CDIR
    public var ip4_gateway: String
    public var ip4_dns_1: String
    public var ip4_dns_2: String

    public var availableForEditing = false
    public var portNumber: Int?

    private enum CodingKeys: String, CodingKey {
        case use, ip4_address, ip4_gateway, ip4_dns_1, ip4_dns_2
    }

    func getUpdateJSON() -> JSON {
        var json = originalJson

        json[DbNodeWanStaticIp.use] = use
        json[DbNodeWanStaticIp.ip4_address] = ip4_address
        json[DbNodeWanStaticIp.ip4_gateway] = ip4_gateway
        json[DbNodeWanStaticIp.ip4_dns_1] = ip4_dns_1
        json[DbNodeWanStaticIp.ip4_dns_2] = ip4_dns_2

        return json
    }
}
