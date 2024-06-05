//
//  HTTPManager.swift
//  VeeaKit
//
//  Created by Atesh Hicks on 12/1/17.
//  Copyright © 2017 Max2. All rights reserved.
//

import Foundation

/// Acceptable status codes from the server.
/// Anything other than these trigger a 'server error'
/// handling from the VKHTTPManager once received.
let kVKHTTPManagerAcceptableHTTPCodes = [200, 601, 602, 666]

/**
 
 VKHTTPManager is used to make calls to the unified backend.
 
 VKHTTPManager has only one public function called
 **call** that is used to make the HTTP calls.
 
 - seealso:
 VKHTTPRequest
 
 - note:
 You need to set your VKApplication up in VeeaKit.init
 for VKHTTPManager to work.
 
 - important:
 VKHTTPManager requires the server to return a JSON in a
 specific format, so it can not be used as a generic HTTP call center.
 
 For more information, see the
 [documentation](https://max2team.atlassian.net/wiki/spaces/VeeaKitiOS/pages/110886942/VKHTTPManager)
 
 */
public class VKHTTPManager {
    
    /// We use this to display and hide the network activity indicator.
    fileprivate static var _requestCount = 0
    
    /// Number of requests that are in "open" right now.
    /// VKHTTPManager automatically sets ``isNetworkActivityIndicatorVisible``
    /// to true or false depending on whether or not we have any calls waiting
    /// response from the server.
    ///
    /// ``isNetworkActivityIndicatorVisible`` is set to false once this hits zero.
    /// - important: Do not change this value outside VKHTTPManager.
    fileprivate static var requestCount: Int {
        set(newValue) {
            _requestCount = newValue
            if _requestCount < 0 {
                _requestCount = 0
            }
        }
        get {
            return _requestCount
        }
    }

    public class func call(request: VKHTTPRequest,
                           requireResponseKey: Bool = true) async throws -> (Bool, Data?, Error?, ErrorHandlingData?) {
        do {
            return try await withCheckedThrowingContinuation({(continuation: (CheckedContinuation<(Bool, Data?, Error?, ErrorHandlingData?), Error>)) in
                do {
                    try call(request: request,
                         requireResponseKey: requireResponseKey) { success, result, error,errorData in
                        continuation.resume(returning: (success, result, error, errorData))
                    }
                }
                catch let e { continuation.resume(throwing: e) }
            })
        }
        catch let e { throw e }
    }
    
    // MARK: - Calls
    
    /// Makes a call to the URL provided in the HTTPRequest.
    /// HTTPRequest is responsible for the type of HTTP call (get, post, etc.)
    /// - parameter request:    The request that VKHTTPManager will try to deliver.
    /// - parameter requireResponseKey: Require that any response is wrapped in a response object (if false you just get the json)
    /// - parameter success:    True if the call has succeeded and the server returned a 200 status.
    /// - parameter result:     The ``response`` field of the JSON that the server has returned.
    /// - parameter error:      Any network or JSON reading errors that has occured.
    public class func call(request: VKHTTPRequest,
                           requireResponseKey: Bool = true,
                           result: @escaping (_ success: Bool, _ result: Data?, _ error: Error?, _ errorData: ErrorHandlingData?)->()) throws {
        // Ensure the token is up to date
        AuthorisationManager.shared.accessToken { (token) in
            if !TestsRouter.interceptForMocking {
                guard token != nil else {
                    let error = VKHTTPManagerError.noConnection
                    result(false, nil, error,nil)

                    return
                }
            }
            
            do {
                try doCall(request: request, requireResponseKey: requireResponseKey, result: result)
            }
            catch let error {
                DispatchQueue.main.async(execute: { () -> Void in
                    result(false, nil, error, nil)
                })
            }
        }
    }
    
    public class func returnErrorHandlingData(data:String) -> ErrorHandlingData? {
        do {
            let json = try VKJSON.init(data: data)
            _ = json.lookup(path: "meta.status", defaultValue: "")
            let title = json.lookup(path: "meta.title", defaultValue: "")
            let suggestions = json.lookup(path: "meta.suggestions", defaultValue: [String]())
            let message = json.lookup(path: "meta.message", defaultValue: "")
            let errorDataObject = ErrorHandlingData(title: title, message: message, suggestions: suggestions)
            return errorDataObject
        } catch _ {
               return ErrorHandlingData(title: "", message: "", suggestions: nil)
        }
    }
    
    public class func doCall(request: VKHTTPRequest,
                              requireResponseKey: Bool = true,
                              result: @escaping (_ success: Bool, _ result: Data?, _ error: Error?, _ errorData: ErrorHandlingData?)->()) throws {
        do {
            
            // Check for network connection before anything
            if !VKReachabilityManager.isConnectedToNetwork() {
                result(false, nil, VKHTTPManagerError.noConnection, nil)
                return
            }
            
            var nativeRequest = try self.createRequest(request: request)
            nativeRequest.httpMethod = request.type.rawValue
            
            // If this is a POST or PUT command, let's set up the request body now.
            if ((request.type != .get || request.type != .delete) && request.data != nil) {
                nativeRequest.httpBody = request.data
                nativeRequest.addValue(request.dataContentType, forHTTPHeaderField: "Content-Type")
                nativeRequest.addValue(request.dataContentType, forHTTPHeaderField: "Accept")
            }
            
            VKHTTPManager.requestCount += 1
            
            let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
            session.configuration.timeoutIntervalForRequest = TimeInterval(request.timeout)
            session.configuration.timeoutIntervalForResource = TimeInterval(request.timeout)

            let task = session.dataTask(request: nativeRequest) { responseResult, rError in
                let rData = responseResult.data

                VKHTTPManager.requestCount -= 1

                if (rError != nil) {
                    DispatchQueue.main.async {
                        //VKLog(rError.debugDescription)
                        result(false, nil, rError!, nil)
                    }
                    return
                }
                let httpStatusCode = responseResult.httpCode
                if (rData == nil || rData?.count == 0) {

                    if httpStatusCode >= 200 && httpStatusCode <= 299 {
                        DispatchQueue.main.async {
                            result(true, nil, nil,nil)
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        result(false, nil, VKHTTPManagerError.didNotReceiveData, nil)
                    }
                    return
                }
              
                let receivedData = String(decoding: rData!, as: UTF8.self)
                // Lets try to read the JSON.
                do {

                    if !requireResponseKey {
                        
                        var errorDataObject = ErrorHandlingData(title: "", message: "", suggestions: nil)
                        var isError = false
                        var responseData: Data? = rData
                        var error: Error? = rError
                      
                        if httpStatusCode >= 200 && httpStatusCode <= 299 {
                            responseData = rData
                        }
                        else {
                            isError = true
                            errorDataObject = returnErrorHandlingData(data: receivedData)!
                            switch httpStatusCode {
                            case 400:
                                error = VKHTTPManagerError.serverError(error: errorDataObject.message ?? "")
                            case 401:
                                error = VKHTTPManagerError.unauthorized
                            case 403:
                                error = VKHTTPManagerError.forbidden
                                Task { await UserSessionManager.shared.loadUser() }
                            case 404:
                                error = VKHTTPManagerError.notFound
                            case 410:
                                error = VKHTTPManagerError.updateRequired
                                UpdateRequired.updateRequired = true
                            case 498:
                                error = VKHTTPManagerError.updateRequired
                                UpdateRequired.updateRequired = true
                            case 500:
                                error = VKHTTPManagerError.serverError(error: "Oops! something went wrong.")
                            default:
                                // Read any error messages we might have in the meta.
                                let errorMessage = "Something unexpected has happened. Please try again(1)."
                                error = VKHTTPManagerError.serverError(error: errorMessage)
                                responseData = nil
                            }
                        }

                        DispatchQueue.main.async(execute: { () -> Void in
                            result(!isError, responseData, error , errorDataObject)
                        })

                    }
                    else{
                        // if backend does not send status code, the status code from URLResponse will be used
                        let json = try VKJSON.init(data: receivedData)
                        let status = json.lookup(path: "meta.status", defaultValue: httpStatusCode)
                        let title = json.lookup(path: "meta.title", defaultValue: "")
                        let suggestions = json.lookup(path: "meta.suggestions", defaultValue: [String]())
                        let message = json.lookup(path: "meta.message", defaultValue: "")

                        var isError = false
                        var responseData: Data? = rData
                        var error: Error? = rError
                        let errorDataObject = ErrorHandlingData(title: title, message: message, suggestions: suggestions)
                        if status != 200 {
                            isError = true
                            error = VKHTTPManagerError.serverError(error: message)

                            switch status {
                            case 401:
                                let errorMessage = json.lookup(path: "meta.message", defaultValue: VKHTTPManagerError.unauthorized.localizedDescription)
                                error = VKHTTPManagerError.serverError(error: errorMessage)
                            case 403:
                                let errorMessage = json.lookup(path: "meta.message", defaultValue: VKHTTPManagerError.forbidden.localizedDescription)
                                error = VKHTTPManagerError.serverError(error: errorMessage)
                                Task { await UserSessionManager.shared.loadUser() }
                            case 410:
                                let errorMessage = json.lookup(path: "meta.message", defaultValue: VKHTTPManagerError.updateRequired.localizedDescription)
                                error = VKHTTPManagerError.serverError(error: errorMessage)
                                UpdateRequired.updateRequired = true
                            case 498:
                                let errorMessage = json.lookup(path: "meta.message", defaultValue: VKHTTPManagerError.updateRequired.localizedDescription)
                                error = VKHTTPManagerError.serverError(error: errorMessage)
                                UpdateRequired.updateRequired = true
                            case 500:
                                let errorMessage = json.lookup(path: "meta.message", defaultValue: "Oops! something went wrong.")
                                error = VKHTTPManagerError.serverError(error: errorMessage)
                            default:
                                // Read any error messages we might have in the meta.
                                let errorMessage = json.lookup(path: "meta.message", defaultValue: "Something unexpected has happened. Please try again(2).")
                                error = VKHTTPManagerError.serverError(error: errorMessage)
                                responseData = nil
                            }
                        } else {
                            if !requireResponseKey {
                                responseData = VKDecoder.serializeData(obj: json)
                            }
                            else {
                                // Check for "response" part.
                                var response: Any? = json.lookup(key: "response", type: VKJSON.self)
                                if response == nil {
                                    response = json.lookup(key: "response", type: [VKJSON].self)
                                }

                                if response == nil {
                                    // Server did not return us a response.
                                    isError = false // To be changed later when backedn sends response for all requests
                                    responseData = nil
                                    error = VKHTTPManagerError.didReceiveInValidResponse
                                } else {
                                    responseData = VKDecoder.serializeData(obj: response)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            result(!isError, responseData, error, errorDataObject)
                        }

                    }


                } catch let error {
                    DispatchQueue.main.async {
                        let errData = ErrorHandlingData(title: "", message: "", suggestions: [])
                        result(false, nil, error, errData)
                    }
                }
            }

            task?.resume()
        } catch let error {
            DispatchQueue.main.async {
                let errData = ErrorHandlingData(title: "", message: "", suggestions: [])
                result(false, nil, error,errData)
            }
        }
    }
}

public struct ErrorHandlingData: Codable {
    public let title: String?
    public let message: String?
    public let suggestions: [String]?
}
