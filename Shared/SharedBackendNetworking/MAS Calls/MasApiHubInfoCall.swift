//
//  MasApiHubInfoCall.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 11/07/2022.
//

import Foundation


/// A cut down version of the same class in the main project
/// This is just used for getting mas connection info
public class MasApiHubInfoCall {
    var hubInfo: [HubInfo]?

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

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    //print(String(describing: error))
                    completion((false, "No Data"))

                    return
                }

                //print(String(data: data, encoding: .utf8)!)
                self.decodeResponse(data: data, completion: completion)
            }
        }

        task.resume()
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
}

public struct HubInfo: Codable {
    public let ID: Int

    public let Connected: Bool
}
