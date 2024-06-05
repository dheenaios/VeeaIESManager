//
//  EndPointConfigManager.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 16/06/2022.
//

import Foundation

public class EndPointConfigManager {

    private struct PresetEndPointOptions {
        static var realmPath: String {
            return "/auth/realms/"
        }

        struct Dev {
            static let mas = "mas.dev.veeaplatform.net"
            static let auth = "https://auth.dev.veeaplatform.net" + PresetEndPointOptions.realmPath
            static let enroll = "dev.veeaplatform.net"

            static func config() -> EndPointConfig {
                let config = EndPointConfig.init(type: .dev,
                                                 enrollmentUrl: enroll,
                                                 authUrl: auth,
                                                 masUrl: mas)
                return config
            }
        }

        struct Qa {
            static let mas = "qamas.veea.io"
            static let auth = "https://qa-auth.veea.co" + PresetEndPointOptions.realmPath
            static let enroll = "qa.veea.co"

            static func config() -> EndPointConfig {
                let config = EndPointConfig.init(type: .qa,
                                                 enrollmentUrl: enroll,
                                                 authUrl: auth,
                                                 masUrl: mas)
                return config
            }
        }

        struct Prod {
            static let mas = "mas.zone1.veea.io"
            static let auth = "https://auth.veea.co" + PresetEndPointOptions.realmPath
            static let enroll = "dweb.veea.co"

            static func config() -> EndPointConfig {
                let config = EndPointConfig.init(type: .production,
                                                 enrollmentUrl: enroll,
                                                 authUrl: auth,
                                                 masUrl: mas)
                return config
            }
        }
    }

    public enum EndPointType: Int {
        case production
        case qa
        case dev
        case custom
    }

    public func getConfigFor(type: EndPointType) -> EndPointConfig {
        switch type {
        case .production:
            return PresetEndPointOptions.Prod.config()
        case .qa:
            return PresetEndPointOptions.Qa.config()
        case .dev:
            return PresetEndPointOptions.Dev.config()
        case .custom:
            return currentConfig()
        }
    }

    public func currentConfig() -> EndPointConfig {

        // Load the stored config.
        let mas = BackEndEnvironment.masApiBaseUrl
        let auth = BackEndEnvironment.authRealm
        let enroll = BackEndEnvironment.ub

        let loadedConfig = EndPointConfig.init(type: .custom,
                                               enrollmentUrl: enroll,
                                               authUrl: auth,
                                               masUrl: mas)

        // Check it for its type
        if loadedConfig == PresetEndPointOptions.Prod.config() {
            return PresetEndPointOptions.Prod.config()
        }
        else if loadedConfig == PresetEndPointOptions.Qa.config() {
            return PresetEndPointOptions.Qa.config()
        }
        else if loadedConfig == PresetEndPointOptions.Dev.config() {
            return PresetEndPointOptions.Dev.config()
        }

        return loadedConfig
    }

    public func setConfig(config: EndPointConfig) {
        BackEndEnvironment.authRealm = config.authEndpointAndRealm
        BackEndEnvironment.ub = config.enrollmentEndpoint
        BackEndEnvironment.enrollmentBaseUrl = config.enrollmentEndpoint + "/enrollment"
        BackEndEnvironment.masApiBaseUrl = config.masEndpoint
        AuthorisationManager.shared.reset()
    }

    public init(){}

    public class EndPointConfig: Equatable {

        /// Does not match the type value
        public static func == (lhs: EndPointConfigManager.EndPointConfig,
                               rhs: EndPointConfigManager.EndPointConfig) -> Bool {
            return lhs.enrollmentEndpoint == rhs.enrollmentEndpoint &&
                lhs.authEndpointAndRealm == rhs.authEndpointAndRealm &&
                lhs.masEndpoint == rhs.masEndpoint
        }

        public let type: EndPointType
        public let enrollmentEndpoint: String
        public let authEndpointAndRealm: String
        public let masEndpoint: String

        var description: String {
            return "Type: \(type)\nEnrollment Endpoint: \(enrollmentEndpoint)\nAuth Endpoint: \(authEndpointAndRealm)\nMAS Endpoint: \(masEndpoint)"
        }

        public init(type: EndPointType,
             enrollmentUrl: String,
             authUrl: String,
             masUrl: String) {
            self.type = type
            self.enrollmentEndpoint = enrollmentUrl
            self.authEndpointAndRealm = authUrl
            self.masEndpoint = masUrl
        }
    }
}
