//
//  AuthorisationManager+UserInfo.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 04/11/2022.
//

import Foundation
import AppAuth

extension AuthorisationManager {
    public func getUserInfo() async -> Bool {
        return await withCheckedContinuation({ (continuation: CheckedContinuation<Bool, Never>) in
            self.authState?.performAction() { (accessToken, idToken, error) in
                guard let accessToken = accessToken,
                      error == nil else {
                    continuation.resume(returning: false)
                    return
                }

                self.debugSession!.sendDataWith(request: self.urlRequest(accessToken)) { result, error in

                    guard !self.responseIsInError(error: error),
                          let httpCode = self.getHttpCode(result: result),
                          let data = self.getData(result: result),
                          let json = self.getResponseJson(data: data) else {
                        continuation.resume(returning: false)
                        return
                    }

                    let responseText: String? = String(data: data, encoding: String.Encoding.utf8)
                    if httpCode != 200 {
                        if httpCode == 401 {
                            self.handle401Response(responseText: responseText, json: json, error: error)
                            continuation.resume(returning: false)

                            return

                        }

                        let error = "HTTP: \(httpCode), Response: \(responseText ?? "RESPONSE_TEXT")"
                        //print(error)
                        self.delegate?.gotUserInfoResult(success: (false, error, nil))
                        continuation.resume(returning: false)

                        return
                    }

                    guard let user = self.createUser(data: data) else {
                        continuation.resume(returning: false)
                        return
                    }

                    self.lastUser = user
                    self.delegate?.gotUserInfoResult(success: (true, "Success: \(json)", user))
                    continuation.resume(returning: true)
                }
            }
        })
    }

    public func getUserInfo(completed: @escaping (Bool) -> Void) {
        self.authState?.performAction() { (accessToken, idToken, error) in

            if error != nil  {
                //print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")

                UserSessionManager.shared.isUserLoggedIn = false
                completed(false)

                return
            }
            guard let accessToken = accessToken else {
                return
            }

            self.debugSession!.sendDataWith(request: self.urlRequest(accessToken)) { result, error in

                guard !self.responseIsInError(error: error),
                      let httpCode = self.getHttpCode(result: result),
                      let data = self.getData(result: result),
                      let json = self.getResponseJson(data: data)else {
                    completed(false)
                    return
                }

                let responseText: String? = String(data: data, encoding: String.Encoding.utf8)

                if httpCode != 200 {
                    if httpCode == 401 {
                        self.handle401Response(responseText: responseText, json: json, error: error)
                        completed(false)
                        return
                    }

                    let error = "HTTP: \(httpCode), Response: \(responseText ?? "RESPONSE_TEXT")"
                    //print(error)
                    self.delegate?.gotUserInfoResult(success: (false, error, nil))
                    completed(false)

                    return
                }

                guard let user = self.createUser(data: data) else {
                    completed(false)
                    return
                }

                self.lastUser = user
                self.delegate?.gotUserInfoResult(success: (true, "Success: \(json)", user))
                completed(true)
            }
        }
    }

    // MARK: - Private Functions

    private func urlRequest(_ accessToken: String) -> URLRequest {
        var urlRequest = URLRequest(url: self.userInfoEndPoint)
        urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]

        return urlRequest
    }

    private func responseIsInError(error: Error?) -> Bool {
        guard let error else {
            return false
        }

        let errorMessage = "HTTP request failed \(error.localizedDescription)"
        self.delegate?.gotUserInfoResult(success: (false, errorMessage, nil))
        return true
    }

    private func getHttpCode(result: URLRequestResult) -> Int? {
        guard let response = result.response as? HTTPURLResponse else {
            //print("Non-HTTP response")
            self.delegate?.gotUserInfoResult(success: (false, "Non-HTTP response", nil))
            return nil
        }

        return response.statusCode
    }

    private func getData(result: URLRequestResult) -> Data? {
        guard let data = result.data else {
            //print("HTTP response data is empty")
            self.delegate?.gotUserInfoResult(success: (false, "HTTP response data is empty", nil))
            return nil
        }

        return data
    }

    private func getResponseJson(data: Data) -> [AnyHashable: Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return json
        } catch {
            //print("JSON Serialization Error")
            self.delegate?.gotUserInfoResult(success: (false, "JSON Serialization Error", nil))
            return nil
        }
    }

    private func handle401Response(responseText: String?,
                                   json: [AnyHashable: Any]?,
                                   error: Error?) {

        // "401 Unauthorized" generally indicates there is an issue with the authorization
        // grant. Puts OIDAuthState into an error state.
        let oauthError = OIDErrorUtilities.resourceServerAuthorizationError(withCode: 0,
                                                                            errorResponse: json,
                                                                            underlyingError: error)
        self.authState?.update(withAuthorizationError: oauthError)

        let error = "Authorization Error (\(oauthError)). Response: \(responseText ?? "RESPONSE_TEXT")"
        //print(error)

        self.delegate?.gotUserInfoResult(success: (false, error, nil))
    }

    private func createUser(data: Data) -> VHUser? {
        guard let user = VKDecoder.decode(type: VHUser.self,
                                          data: data) else {
            self.delegate?.gotUserInfoResult(success: (false, "Could not encode OpenID response", nil))

            return nil
        }

        return user
    }
}
