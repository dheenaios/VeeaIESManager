//
//  HubInfoCall.swift
//  MAS API
//
//  Created by Richard Stockdale on 28/08/2020.
//  Copyright © 2020 Richard Stockdale. All rights reserved.
//

import Foundation
import SharedBackendNetworking

public class MasApiHubInfoCall {
    var hubInfo: [HubInfo]?
    var meshStatusAPIRepsonse: MeshStatusResponse?
    
    /// Request information for given hubs
    /// - Parameters:
    ///   - token: The auth token
    ///   - serials: the serials of the hubs. Comma seperated
    ///   - baseUrl: the base url of the environment we are addressing
    ///   - completion: Completion closure
    public func makeCallWith(token: String,
                             serials: [String],
                             baseUrl: String,
                             completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        let url = "https://\(baseUrl)/api/v2/nodes?unit_serials="
        
        // Encode the commas in the serials
        let encodedSerials = serials.joined(separator: "%2C")
        
        // Create the request
        var request = URLRequest(url: URL(string: url + encodedSerials)!,timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.sendDataWith(request: request) { result, error in
            guard let data = result.data else {
                //print(String(describing: error))
                completion((false, "No Data"))

                return
            }

            //print(String(data: data, encoding: .utf8)!)
            self.decodeResponse(data: data, completion: completion)
        }
    }
    
    private func decodeResponseCopy(data: Data, completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            hubInfo = try decoder.decode([HubInfo].self, from: data)
            completion((true, nil))
        }
        catch {
            //print(error.localizedDescription)
            completion((false, error.localizedDescription))
        }
    }
   
    func dataToJSON(data: Data) -> Any? {
       do {
           return try JSONSerialization.jsonObject(with: data, options: [])
       } catch let myJSONError {
           print(myJSONError)
       }
       return nil
    }
    
    private func decodeResponseForStatusAPI(data: Data, completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let mdata = String(data: data, encoding: .utf8)
        do {
            meshStatusAPIRepsonse = try decoder.decode(MeshStatusResponse.self, from: data)
            completion((true, nil))
        }
        catch {
            completion((false, error.localizedDescription))
        }
    }
    
    private func decodeResponse(data: Data, completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            hubInfo = try decoder.decode([HubInfo].self, from: data)
            completion((true, nil))
        }
        catch {
            //print(error.localizedDescription)
            completion((false, error.localizedDescription))
        }
    }
    
    public func makeCallForHealthAPI(token: String,
                             meshId: String,
                             baseUrl: String,
                             completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        let url = EnrollmentEndpoint.getMeshStatus(meshId).value
        // Create the request
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.sendDataWith(request: request) { result, error in
            guard let data = result.data else {
                completion((false, "No Data"))

                return
            }
            self.decodeResponseForStatusAPI(data: data, completion: completion)
        }
    }
    
    public func makeCallForDeviceHealthAPI(token: String,
                             deviceId: String,
                             baseUrl: String,
                             completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        let url = EnrollmentEndpoint.getDeviceStatus(deviceId).value
        // Create the request
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.sendDataWith(request: request) { result, error in
            guard let data = result.data else {
                completion((false, "No Data"))

                return
            }
            self.decodeResponseForStatusAPI(data: data, completion: completion)
        }
    }
    
}

public struct HubInfo: Codable {
    
    // This was used to decide if the hub was available.
    // VHM-758: changes this to make use of the "connected" property on the root object
    public struct NodeState: Codable {
        @DecodableDefault.False var Healthy: Bool
        @DecodableDefault.False var Operational: Bool
        @DecodableDefault.False var RebootRequired: Bool
        
        var description: String {
            get {
                return """
                # Node State
                
                - Healthy: \(Healthy)
                - Operational: \(Operational)
                - Reboot Required: \(RebootRequired)
                """
            }
        }
        
        public var isAvailable: Bool {
            get {
                return Healthy && Operational
            }
        }
    }
    
    public let ID: Int
    public let CreatedAt: String
    public let UpdatedAt: String
    public let VMeshId: Int
    public let Address: String
    public let Port: Int
    public let Name: String
    public let HostName: String
    public let Manager: Bool
    public let Serial: String
    public let UnitSerial: String
    public let DockerId: String
    public let DockerState: String
    public let LastSeenOnWebsocket: String
    public let LastSeenInPost: String
    public let LastSeenInPoll: String
    public let LastReinstall: String
    public let CxnTransitionTimestamp: String
    
    // Used to detect if hub can be contacted over the MAS API
    // As of VHM-758 (see NodeState above)
    public let Connected: Bool
    
    public let NodeState: NodeState
    
    public var description: String {
        get {
            return """
            # Hub Info
            
            - ID: \(ID)
            - CreatedAt: \(CreatedAt)
            - UpdatedAt: \(UpdatedAt)
            - VMeshId: \(VMeshId)
            - Address: \(Address)
            - Port: \(Port)
            - Name: \(Name)
            - HostName: \(HostName)
            - Manager: \(Manager)
            - Serial: \(Serial)
            - UnitSerial: \(UnitSerial)
            - DockerId: \(DockerId)
            - DockerState: \(DockerState)
            - LastSeenOnWebsocket: \(LastSeenOnWebsocket)
            - LastSeenInPost: \(LastSeenInPost)
            - LastSeenInPoll: \(LastSeenInPoll)
            - LastReinstall: \(LastReinstall)
            - CxnTransitionTimestamp: \(CxnTransitionTimestamp)
            - Connected: \(Connected)
            
            \(self.NodeState.description)
            """
        }
    }
}
