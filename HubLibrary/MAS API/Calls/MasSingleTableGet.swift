//
//  MasSingleTableGet.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 14/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class MasSingleTableGet {
    public typealias MasApiGetResult = (MasApiCallResponse) -> Void
    
    public var callResponse: MasApiCallResponse?
    public let tableName: String
    
    private var completion: MasApiGetResult?
    private let masConnection: MasConnection
    
    
    init(masConnection: MasConnection, tableName: String) {
        self.masConnection = masConnection
        self.tableName = tableName
    }
    
    func makeCall(completion: @escaping MasApiGetResult) {
        URLSession.sendDataWith(request: request) { result, error in
            guard let data = result.data else {
                //print(String(describing: error))
                var masResponse = MasApiCallResponse(nodeId: 0,
                                                     tableName: self.tableName,
                                                     json: nil,
                                                     data: Data())

                masResponse.error = APIError.Failed(message: error?.localizedDescription ?? "No data")
                completion(masResponse)

                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSON {
                let masResponse = MasApiCallResponse(nodeId: self.masConnection.nodeId,
                                                     tableName: self.tableName,
                                                     json: json,
                                                     data: data,
                                                     error: nil)

                completion(masResponse)
            }
            else {
                var masResponse = MasApiCallResponse(nodeId: 0,
                                                     tableName: self.tableName,
                                                     json: nil,
                                                     data: data)

                masResponse.error = APIError.Failed(message: "Error encoding JSON")

                completion(masResponse)
            }
        }        
    }
    
    private var request: URLRequest {
        get {
            let url = masConnection.urlFor(tableName: tableName)
            var request = URLRequest(url: URL(string: url)!, timeoutInterval: Double.infinity)
            request.addValue(AuthorisationManager.shared.formattedAuthToken!, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            return request
        }
    }
}
