//
//  Environment.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 16/06/2022.
//

import Foundation

public let _AppEndpoint: (String) -> String = {
    return BackEndEnvironment.scheme + BackEndEnvironment.enrollmentBaseUrl + $0
}

public let _GroupEndPoint : (String) -> String = {
    return BackEndEnvironment.scheme + BackEndEnvironment.ub + $0
}

public let _VeeaUBEndpoint: (String) -> String = {
    return BackEndEnvironment.scheme + BackEndEnvironment.ub + $0
}

public struct BackEndEnvironment {
    /// User default keys
    // Keys are appended with Mt to make multitennancy distinct from single tennancy
    fileprivate enum EndPointKeys: String {
        case baseUrlKey = "_baseUrlKeyMt"
        case authUrlKey = "_authUrlKeyMt"
        case authBackendKey = "_authBackendKeyMt"
        case ubKey = "_ubKeyMt"
        case authCallbackUrlKey = "_authCallbackUrlKeyMt"
        case authRealm = "_authRealmMt"
        case masApiKey = "_masApiMt"

        var value: String {
            return self.rawValue
        }
    }

    static public var isHome: Bool {
        // Get the realm name. If it contains home, then this is the home app
        let realm = BackEndEnvironment.authRealm + VeeaRealmsManager.selectedRealm
        if realm.lowercased().contains("home") {
            return true
        }

        return false
    }

    static public let appstoreUrl = "https://apps.apple.com/us/app/veeahub-manager/id1451992503"
    static let scheme = Configuration.shared.getPlistString(.httpScheme)
    static let clientID = Configuration.shared.getPlistString(.clientID)
    static public let internalBuild = Configuration.shared.getBool(.internalBuild)

    @SharedUserDefaultsBacked(key: EndPointKeys.baseUrlKey.value,
                        defaultValue: Configuration.shared.getEndPoint(.enrollmentURL))
    static var enrollmentBaseUrl: String

    @SharedUserDefaultsBacked(key: EndPointKeys.authUrlKey.value,
                        defaultValue: Configuration.shared.getEndPoint(.authUrl))
    static var authUrl: String


    @SharedUserDefaultsBacked(key: EndPointKeys.ubKey.value,
                        defaultValue: Configuration.shared.getPlistString(.ubBase))
    static var ub: String

    @SharedUserDefaultsBacked(key: EndPointKeys.authCallbackUrlKey.value,
                        defaultValue: Configuration.shared.getEndPoint(.authCallbackURL))
    static var authCallbackUrl: String

    @SharedUserDefaultsBacked(key: EndPointKeys.masApiKey.value,
                        defaultValue: Configuration.shared.getPlistString(.masApi))
    static public var masApiBaseUrl: String
}

// MARK: - OAuth and OpenID Variables
extension BackEndEnvironment {
    @SharedUserDefaultsBacked(key: EndPointKeys.authRealm.value,
                        defaultValue: Configuration.shared.getPlistString(PlistKey.authRealm))
    public static var authRealm: String
}

/// Keys in the Info.plist
fileprivate enum PlistKey: String {
    case httpScheme = "HTTP_SCHEME"
    case ubBase = "VEEA_UB_BASE"
    case clientID = "VEEA_APP_CLIENT_ID"
    case internalBuild = "INTERNAL_BUILD"
    case authRealm = "VEEA_AUTH_REALM"
    case masApi = "VEEA_MAS_API"

    var value: String {
        return self.rawValue
    }
}

/// End points [base]/[endpoint]
fileprivate enum EndPoints {
    case enrollmentURL
    case authUrl
    case authCallbackURL
}

fileprivate class Configuration {

    static let shared = Configuration()

    var infoDict: [String: Any]  {
        get {
            if let dict = Bundle.main.infoDictionary {
                return dict
            }else {
                fatalError("Plist file not found")
            }
        }
    }

    func getEndPoint(_ key: EndPoints) -> String {
        switch key {
        case .authCallbackURL:
            return BackEndEnvironment.ub + "/app/callback"

        case .authUrl:
            return BackEndEnvironment.ub + "/auth"

        case .enrollmentURL:
            return BackEndEnvironment.ub + "/enrollment"
        }
    }

    func getPlistString(_ key: PlistKey) -> String {
        return infoDict[key.value] as! String
    }

    func getBool(_ key: PlistKey) -> Bool {
        return infoDict[key.value] as! Bool
    }
}
