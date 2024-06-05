//
//  HubApiGetRequest.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 12/04/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit

class HubApiRequester: NSObject {
    
    private let tag = "HubApiGetRequest"
    private var authRetryCount = 0
    private let maxAuthRetrys = 2
    
    public static let shared = HubApiRequester()
    
    /// Send a request with a single configuration (at the moment, multiple configs are not needed, add as needed)
    ///
    /// - Parameters:
    ///   - Connection: Connection to communicate vai
    ///   - config: The config for the request
    ///   - delegate: Callback
    public func sendRequest(connection: VeeaHubConnection?,
                            config :HubApiGetConfigRequest,
                            response :@escaping (RequestResponce) -> Void) {
        guard let connection = connection else {
            response(RequestResponce(json: nil, error: APIError.NoConnection))
            return
        }
        
        validateUpdateToken(connection: connection) { (success, description) in
            if success {
                self.doSecureDocRequest(connection: connection, configs: [config], requestResponse: response)
            }
            else {
                var d = "No error description"
                if let description = description {
                    d = description
                }
                
                response(RequestResponce(json: nil, error: APIError.Failed(message: d)))
            }
        }
    }
    
    private func doSecureDocRequest(connection: VeeaHubConnection,
                                    configs :[HubApiGetConfigRequest],
                                    requestResponse :@escaping (RequestResponce) -> Void) {
        guard let request = SecureURLRequestFactory.createPutRequest(connection: connection,
                                                                     configs: configs) else {
            requestResponse(RequestResponce(json: nil, error: APIError.Failed(message: "Could not create secure request response")))
            
            return
        }
        
        makeDataRequest(request: request,
                        requestResponse: requestResponse)
    }

    /// Send a request with a single configuration (at the moment, multiple configs are not needed, add as needed)
    ///
    /// - Parameters:
    ///   - connection: connection to communicate over
    ///   - config: The config for the request
    ///   - delegate: Callback
    public func sendUpdateRequest(connection: VeeaHubConnection,
                                  config :HubApiUpdateConfigRequest,
                                  response :@escaping (RequestResponce) -> Void) {
        validateUpdateToken(connection: connection) { (success, description) in
            if success {
                self.doSecureUpdateRequest(connection: connection,
                                           config: config,
                                           requestResponse: response)
            }
            else {
                var d = "No error description"
                if let description = description {
                    d = description
                }
                
                response(RequestResponce(json: nil, error: APIError.Failed(message: d)))
            }
        }
    }
    
     private func doSecureUpdateRequest(connection: VeeaHubConnection,
                                        config :HubApiUpdateConfigRequest,
                                        requestResponse :@escaping (RequestResponce) -> Void) {
        guard let request = SecureURLRequestFactory.createPatchRequest(connection: connection,
                                                                       config: config) else {
            requestResponse(RequestResponce(json: nil, error: APIError.Failed(message: "Could not patch create request")))
            
            return
        }
        
        authRetryCount = 0
        makeDataRequest(request: request, requestResponse: requestResponse)
    }
    
    internal func makeDataRequest(request: URLRequest,
                                  requestResponse: @escaping (RequestResponce) -> Void) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        session.sendDataWith(request: request) { result, error in
            if result.httpCode != 200 {
                Logger.log(tag: "SecureRequester", message: "Unexpected httpcode: \(result.httpCode)")
            }

            // If we get a data response
            if let data = result.data {
                if request.httpMethod == "PATCH" {
                    if let error = error {
                        requestResponse(RequestResponce(error: APIError.Failed(message: "\(result.httpCode): \(error.localizedDescription)")))
                    }
                    else {
                        requestResponse(RequestResponce())
                    }
                }
                else {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSON {
                        if let error = error {
                            requestResponse(RequestResponce(error: APIError.Failed(message: "\(result.httpCode): \(error.localizedDescription)")))
                        }
                        else {
                            requestResponse(RequestResponce(json: json, error: nil))
                        }
                    }
                    else {
                        SecureAPIAuthorisation.shared.deleteToken() // Delete the token. It may be the connection expiring the token
                        requestResponse(RequestResponce(error: APIError.Failed(message: "Could not parse JSON, but no error was received. Code: \(result.httpCode)")))

                        if let url = request.url {
                            Logger.log(tag: "SecureRequester", message: "Bad json response for request to \(url)")
                        }
                    }
                }
            }
            else { // If data response is null then the call failed
                if let e = error {
                    if self.authRetryCount < self.maxAuthRetrys {
                        self.authRetryCount += 1
                        self.makeDataRequest(request: request, requestResponse: requestResponse)
                    }
                    else {
                        SecureAPIAuthorisation.shared.deleteToken() // Delete the token. It may be the connection expiring the token
                        requestResponse(RequestResponce(error: APIError.NoData(reason: e)))
                    }
                }
            }
        }
    }
    
    // MARK: - Logging in and token validity checks
    
    /// Checks we have a valid token. If we do not, it goes and fetches one. This should be called before making any secure API calls
    ///
    /// - Parameters:
    ///   - connection: The connected we are using
    ///   - completion: Completion handler
    internal func validateUpdateToken(connection :VeeaHubConnection,
                                      completion: @escaping SecureAPIAuthorisation.LoginSuccessDelegate) {
        guard let authToken = SecureAPIAuthorisation.shared.getCachedToken() else {
            Logger.log(tag: tag, message: "Making call to get new auth token")
            login(connection: connection) { (success, description) in
                completion((success, description))
            }
            
            return
        }
        
        Logger.log(tag: tag, message: "Existing token appears to be valid")
        completion((true, authToken))
    }
    
    private func login(connection: VeeaHubConnection,
                       completion: @escaping SecureAPIAuthorisation.LoginSuccessDelegate) {
        SecureAPIAuthorisation.shared.login(connection: connection) { (success, description) in
            completion((success, description))
        }
    }
}

extension HubApiRequester: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:challenge.protectionSpace.serverTrust!))
    }
}

// MARK: - Firewall

extension HubApiRequester {
    func getAllFirewallRules(connection: VeeaHubConnection, completion: @escaping FirewallDelegate) {
        // Single call to the firewall db
        let config = HubApiGetConfigRequest(tableName: "node_firewall", keys: [String]())
        
        HubApiRequester.shared.sendRequest(connection: connection, config: config) { (response) in
            guard let responseBody = response.responseBody,
                  let allRules = responseBody["node_firewall"] else {
                completion(nil, response.error)
                return
            }
            
            var firewallRules = [FirewallRule]()
            
            // Accept Deny rules
            if let rules = allRules["firewall_rules"] as? [JSON] {
                for rule in rules {
                    let r = FirewallRule.init(json: rule)
                    firewallRules.append(r)
                }
            }
            
            // Forward rules
            if let rules = allRules["forward_rules"] as? [JSON] {
                for rule in rules {
                    let r = FirewallRule.init(json: rule)
                    firewallRules.append(r)
                }
            }
            
            completion(firewallRules, response.error)

        }
    }
}

extension HubApiRequester {
    func createJSONData(requestJSON: [String : [String]]) -> Data? {
        do {
            let json = try JSONSerialization.data(withJSONObject: requestJSON, options:.prettyPrinted)
            
            return json
        }
        catch {
            Logger.log(tag: tag, message: "Error converting request json to data")
            return nil
        }
    }
}

public class RequestResponce {
    public var error :APIError?
    public var responseBody :[String : [String : Any]]?
    
    
    /// Get a specific value from the response
    ///
    /// - Parameters:
    ///   - tableName: The name of the table the value lives on
    ///   - key: The key for the value
    /// - Returns: The value found. Or null
    func getResponse(forTableName tableName: String, key: String) -> Any? {
        guard let body = responseBody else {
            return nil
        }
        
        for item in body {
            if tableName == item.key {
                let value = item.value[key]
                
                return value
            }
        }
        
        return nil
    }
    
    // Used for patch requests where we expect no JSON
    init() {}
    
    init(error :APIError) {
        self.error = error
    }
    
    init(json :Any?, error :APIError?) {
        self.error = error
        if let jsonResult = json as? [String : [String : Any]] {
            responseBody = jsonResult
        }
        else {
            let errorDesc = error?.errorDescription()
            
            if json == nil {
                self.error = APIError.Failed(message: "Nothing was returned: \(errorDesc ?? "")")
            }
            else {
                self.error = APIError.Failed(message: "Data structure is incorrect: \(errorDesc ?? "")" )
            }
        }
    }
}
