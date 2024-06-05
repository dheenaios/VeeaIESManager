//
//  VeeaRealmsGet.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 26/11/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class VeeaRealmsManager {
    
    private static let endPointManager = EndPointConfigManager()
    
    private let tag = "VeeaRealmsManager"
    private let kSavedRealmsKey = "savedRealmsKey"
    private static let kSelectedRealmKey = "kSelectedRealmKey"
    
    private static var kUserAddedRealmsKey: String {
        let devEnvKey = "kUserAddedRealmsKeyDev"
        let qaEnvKey = "kUserAddedRealmsKeyQa"
        let prodEnvKey = "kUserAddedRealmsKeyProd"
        let customEnvKey = "kUserAddedRealmsKeyCustom"
        
        let currentConfig = endPointManager.currentConfig().type
        switch currentConfig {
        case .dev:
            return devEnvKey
        case .qa:
            return qaEnvKey
        case .custom:
            return customEnvKey
        default:
            return prodEnvKey
        }
    }
    
    // The id of the users selected realm
    @SharedUserDefaultsBacked(key: kSelectedRealmKey, defaultValue: "veea")
    static var selectedRealm: String
    
    // Use this only to get the dictionary value for persisting over logouts
    @UserDefaultsBacked(key: kUserAddedRealmsKey, defaultValue: [JSON]())
    static var userAddedRealms: [JSON]
    
    /// All the realms the user has selected
    var allKnownRealms: [RealmDetails] {
        var r = [RealmDetails]()
        
        // THE VEEA REALM
        let veeaRealm = RealmDetails.init(id: "veea", name: "veea")
        r.append(veeaRealm)
        
        // USER ADDED REALMS
        let addedRealms = userAddedRealms()
        for realm in addedRealms {
            r.append(realm)
        }
        
        return r
    }
    
    /// Realms from the server
    var loadedRealms = [RealmDetails]()
    
    func isKnownRealm(realmName: String) -> Bool {
        for realm in loadedRealms {
            if realm.name == realmName {
                return true
            }
        }
        
        return false
    }
    
    func addRealmWith(name: String) {
        
        if name.lowercased() == "veea" {
            Logger.log(tag: tag,
                       message: "User attempted to enter Veea realm which already existed")
            return
        }
        
        guard let realmDetails = realmDetailsFrom(realmName: name) else { return }
        
        // Check the loaded realms
        for realm in allKnownRealms {
            if name == realm.name {
                Logger.log(tag: tag,
                           message: "\("User attempted to enter realm which already existed:".localized()) \(name)")
                return
            }
        }
        
        
        
        userAddedRealm(realm: realmDetails)
    }
    
    public func realmDetailsFrom(realmName: String) -> RealmDetails? {
        for realm in loadedRealms {
            if realm.name == realmName {
                return realm
            }
        }
        
        return nil
    }
    
    func get(completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        guard let url = urlForSelectedEndpoint else {
            completion((false, "Could not create a valid URL".localized()))
            return
        }
        
        let request = getRequest(url: url, method: "GET")

        URLSession.sendDataWith(request: request) { result, error in
            guard let data = result.data else {
                //print(String(describing: error))
                return
            }

            let decoder = JSONDecoder()
            do {
                self.loadedRealms = try decoder.decode([RealmDetails].self, from: data)
                self.saveRealms()
                completion((true, nil))

                return
            }
            catch {
                Logger.logDecodingError(className: "RealmDetails", tag: self.tag, error: error)
                return
            }
        }
    }
    
    private func getRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url ,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        
        return request
    }
    
    
    /// Returns the URL for the selected Environment
    private var urlForSelectedEndpoint: URL? {
        let str = BackEndEnvironment.authRealm
        let url = URL(string: str + "veea/veearealms/realms")
        
        return url
    }
    
    init() {
        if let r = loadRealms() {
            loadedRealms = r
        }
    }
    
    // MARK: - Realm Details
    struct RealmDetails: Codable {
        let id: String
        let name: String
        
        func getDict() -> JSON {
            var j = JSON()
            j["id"] = id
            j["name"] = name
            
            return j
        }
        init(id: String, name: String) {
            self.id = id
            self.name = name
        }
        
        init(j: JSON) {
            id = j["id"] as! String
            name = j["name"] as! String
        }
    }
}

// MARK: - Users realms
extension VeeaRealmsManager {
    private func userAddedRealm(realm: RealmDetails) {
        var realms = userAddedRealms()
        realms.append(realm)
        
        var json = [JSON]()
        
        for r in realms {
            json.append(r.getDict())
        }

        UserDefaults.standard.setValue(json, forKey: VeeaRealmsManager.kUserAddedRealmsKey)
    }
    
    private func userAddedRealms() -> [RealmDetails] {
        if let realms = UserDefaults.standard.value(forKey: VeeaRealmsManager.kUserAddedRealmsKey) as? [JSON] {
            var ar = [RealmDetails]()
            for r in realms {
                ar.append(RealmDetails.init(j: r))
            }
            
            return ar
        }
        
        return [RealmDetails]()
    }
}

// MARK: - Saving and Loading realms from server
extension VeeaRealmsManager {
    fileprivate func saveRealms() {
        var json = [JSON]()
        
        for r in loadedRealms {
            json.append(r.getDict())
        }
        
        UserDefaults.standard.setValue(json, forKey: kSavedRealmsKey)
    }
    
    fileprivate func loadRealms() -> [RealmDetails]? {
        if let realms = UserDefaults.standard.value(forKey: kSavedRealmsKey) as? [JSON] {
            
            var ar = [RealmDetails]()
            for r in realms {
                ar.append(RealmDetails.init(j: r))
            }
            
            return ar
        }
        
        return nil
    }
}
