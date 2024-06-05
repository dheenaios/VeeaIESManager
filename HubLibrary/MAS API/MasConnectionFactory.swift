//
//  MasConnectionFactory.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 08/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

public class MasConnectionFactory {
    
    public typealias HubInfoDelegate = ([HubInfo]?, APIError?) -> Void
    public typealias HealthCheckupAPIDelegate = (MeshStatusResponse?, APIError?) -> Void
    public typealias DeviceStatusAPIDelegate = (MeshStatusResponse?, APIError?) -> Void

    
    public static func getHubInfoFromMas(nodeSerials: [String],
                                         apiToken: String,
                                         baseUrl: String,
                                         completion: @escaping HubInfoDelegate) {
        let hubInfoCall = MasApiHubInfoCall()
        hubInfoCall.makeCallWith(token: apiToken,
                                 serials: nodeSerials,
                                 baseUrl: baseUrl) { (success, message) in
            if !success {
                completion(nil, APIError.Failed(message: message ?? "Unknown error"))
                return
            }
            
            guard let hubs = hubInfoCall.hubInfo else {
                completion(nil, APIError.Failed(message: message ?? "No hub info returned"))
                return
            }
            
            completion(hubs, nil)
        }
    }
    
    public static func makeMasConectionFor(nodeSerial: String,
                                            completion: @escaping(Bool, MasConnection?) -> Void) {
        guard let token = AuthorisationManager.shared.formattedAuthToken else {
            completion(false, nil)
            return
        }
        
        makeMasConnectionFor(nodeSerial: nodeSerial,
                             apiToken: token,
                             baseUrl: BackEndEnvironment.masApiBaseUrl,
                             completion: completion)
    }
    
    /// Creates a connection for the MAS
    public static func makeMasConnectionFor(nodeSerial: String,
                                            apiToken: String,
                                            baseUrl: String,
                                            completion: @escaping(Bool, MasConnection?) -> Void) {
        
        let hubInfoCall = MasApiHubInfoCall()
        hubInfoCall.makeCallWith(token: apiToken,
                                 serials: [nodeSerial],
                                 baseUrl: baseUrl) { (success, message) in
            if !success {
                completion(false, nil)
                return
            }
            
            // TODO: Check if Hub is available on mas
            
            guard let hub = hubInfoCall.hubInfo?.first else {
                completion(false, nil)
                return
            }
            
            let connection = MasConnection.init(nodeId: hub.ID, baseUrl: baseUrl)
            if UserSettings.connectViaMasIfHubNotConnected {
                connection.wasAvailable = true
            }
            else {
                connection.wasAvailable = hub.Connected
            }
            
            completion(true, connection)
        }
    }
  
    public static func getMeshHealthInfoFromMas(meshId: String,
                                         apiToken: String,
                                         baseUrl: String,
                                         completion: @escaping HealthCheckupAPIDelegate) {
        let hubInfoCall = MasApiHubInfoCall()
        hubInfoCall.makeCallForHealthAPI(token: apiToken,
                                         meshId: meshId,
                                 baseUrl: baseUrl) { (success, message) in
            if !success {
                completion(nil, APIError.Failed(message: message ?? "Unknown error"))
                return
            }
            
            guard let meshStatus = hubInfoCall.meshStatusAPIRepsonse else {
                completion(nil, APIError.Failed(message: message ?? "No hub info returned"))
                return
            }
            
            completion(meshStatus, nil)
        }
    }
    
    
    public static func getDeviceHealthInfoFromMas(deviceId: String,
                                         apiToken: String,
                                         baseUrl: String,
                                         completion: @escaping DeviceStatusAPIDelegate) {
        let hubInfoCall = MasApiHubInfoCall()
        hubInfoCall.makeCallForDeviceHealthAPI(token: apiToken, deviceId: deviceId, baseUrl: baseUrl) { (success, message) in
            
            if !success {
                completion(nil, APIError.Failed(message: message ?? "Unknown error"))
                return
            }
            
            guard let deviceStatus = hubInfoCall.meshStatusAPIRepsonse else {
                completion(nil, APIError.Failed(message: message ?? "No hub info returned"))
                return
            }
            
            completion(deviceStatus, nil)
        }
    }
   
}
