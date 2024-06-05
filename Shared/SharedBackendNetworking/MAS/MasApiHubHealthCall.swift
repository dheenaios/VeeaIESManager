//
//  MasApiHubHealthCall.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 21/06/2022.
//

import Foundation

class MasApiHubHealthCall {

    var hubHealth: [HubHealth]?
    
    /// Request information for given hubs
    /// - Parameters:
    ///   - token: The auth token
    ///   - serials: the serials of the hubs. Comma seperated
    ///   - baseUrl: the base url of the environment we are addressing
    ///   - completion: Completion closure
    public func makeCallWith(token: String,
                             serials: [String],
                             completion: @escaping(SuccessAndOptionalMessage) -> Void) {

        let baseUrl = BackEndEnvironment.masApiBaseUrl
        let url = "https://\(baseUrl)/api/v2/nodes?unit_serials="

        // Encode the commas in the serials
        let encodedSerials = serials.joined(separator: "%2C")

        var request = URLRequest(url: URL(string: url + encodedSerials)!,timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.sendDataWith(request: request) { result, error in
            guard let data = result.data else {
                //print(String(describing: error))
                completion((false, "No Data".localized()))

                return
            }

            //print(String(data: data, encoding: .utf8)!)
            self.decodeResponse(data: data, completion: completion)
        }
    }

    private func decodeResponse(data: Data, completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            hubHealth = try decoder.decode([HubHealth].self, from: data)
            completion((true, nil))
        }
        catch {
            //print(error.localizedDescription)
            completion((false, error.localizedDescription))
        }
    }
}

public struct HubHealth: Codable {
    public struct NodeState: Codable {
        var Healthy: Bool
        var Operational: Bool
        var RebootRequired: Bool

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

    public let Name: String
    public let HostName: String
    public let Serial: String
    public let UnitSerial: String
    public let LastSeenInPost: String
    public let LastSeenInPoll: String
    public let Connected: Bool

    public let NodeState: NodeState
}
