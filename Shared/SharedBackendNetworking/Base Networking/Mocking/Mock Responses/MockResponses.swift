//
//  MockResponses.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 25/07/2022.
//

import Foundation

struct MockResponses {

    enum MockResponseError: Error {
        case decodeError
        case unknown
    }

    enum Responses: String {
        // MAS
        case getGroups
        case getMeshDetails
        case getMeshes
        case getProcessingHubs

        // AUTH
        case postAuthTokenResponse
        case getUserInfo
        case getRealms
    }

    static func load(response: Responses) throws -> MockRequestResponse? {
        let data = JsonFileLoader.loadData(response.rawValue + ".json")

        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(MockRequestResponse.self, from: data)
            return decoded
        }
        catch {
            throw MockResponseError.decodeError
        }
    }

    struct MockRequestResponse: Codable {
        let tags: [String]
        let url: String
        let method: String
        let httpCode: Int
        let responseJsonString: String?

        var data: Data? {
            guard let d = responseJsonString?.data(using: .utf8) else {
                return nil
            }

            return d
        }

        var responseJSON: JSON? {
            guard let data = data else {
                return nil
            }

            do {
                let dictResponse = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? JSON
                return dictResponse
            }
            catch {
                return nil
            }
        }

        var responseJSONArray: [JSON]? {
            guard let data = data else {
                return nil
            }

            do {
                let arrResponse = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [JSON]
                return arrResponse
            }
            catch {
                return nil
            }
        }
    }
}
