//
//  MasConnectionFactory.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 11/07/2022.
//

import Foundation


/// Cut down verision of the class in the main project.
/// Will always return connected. We dont wnat to handle the various connection states in the widget
public class MasConnectionFactory {

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
            connection.wasAvailable = true

            completion(true, connection)
        }
    }
}
