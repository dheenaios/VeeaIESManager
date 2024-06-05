//
//  URLSessionAsyncExtensions.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 18/07/2022.
//

import Foundation

/// URLSession extension. All traffic should be sent thought one of the following methods.
/// They allow for interception of requests, during tests and for the return of mocked data.
/// With a little tweeking they can be used for mocking a response during development, if you dont want
/// to use a http proxy.
public extension URLSession {

    // MARK: - Static Methods

    /// Wrapper for URL session. Returned on main thread
    /// - Parameters:
    ///   - request: the URL request
    ///   - completionHandler: Completion handler. Will return a URLRequestResult, and and optional Error
    static func sendDataWith(request: URLRequest,
                             completionHandler: @escaping (URLRequestResult, Error?) -> Void) {
        if TestsRouter.interceptForMocking {
            if let result = TestsRouter.sendTestRequest(request: request) {
                completionHandler(result, nil)
                return
            }
        }

        logRequest(request)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let result = URLRequestResult(request: request, response: response, data: data)
            logResult(result)
            DispatchQueue.main.async {
                completionHandler(result, error)
            }
        }

        task.resume()
    }

    /// Async wrap for URL Session. There is an async equivelent method in iOS 15, but I want to use it now
    /// - Parameter request: URL request to be sent
    /// - Returns: instance of URLRequestResult. Throws if there is an error.
    static func sendDataWith(request: URLRequest) async throws -> URLRequestResult {
        if TestsRouter.interceptForMocking {
            if let result = TestsRouter.sendTestRequest(request: request) {
                return result
            }
        }

        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<URLRequestResult, Error>) in
            logRequest(request)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let result = URLRequestResult(request: request, response: response, data: data)
                logResult(result)
                continuation.resume(returning: result)
            }

            task.resume()
        })
    }

    // MARK: - Instance methods

    // Returns the data task for you to hold on too.
    func dataTask(request: URLRequest,
                      completionHandler: @escaping (URLRequestResult, Error?) -> Void) -> URLSessionDataTask? {
        if TestsRouter.interceptForMocking {
            if let result = TestsRouter.sendTestRequest(request: request) {
                completionHandler(result, nil)
                return nil
            }
        }

        URLSession.logRequest(request)
        let task = self.dataTask(with: request) { data, response, error in
            let result = URLRequestResult(request: request, response: response, data: data)
            URLSession.logResult(result)
            DispatchQueue.main.async {
                completionHandler(result, error)
            }
        }

        return task
    }

    func sendDataWith(request: URLRequest, completionHandler: @escaping (URLRequestResult, Error?) -> Void) {
        if TestsRouter.interceptForMocking {
            if let result = TestsRouter.sendTestRequest(request: request) {
                completionHandler(result, nil)
                return
            }
        }

        URLSession.logRequest(request)
        let task = self.dataTask(with: request) { data, response, error in
            let result = URLRequestResult(request: request, response: response, data: data)
            URLSession.logResult(result)
            DispatchQueue.main.async {
                completionHandler(result, error)
            }
        }

        task.resume()
    }

    /// Async wrap for URL Session. There is an async equivelent method in iOS 15, but I want to use it now
    /// - Parameter request: URL request to be sent
    /// - Returns: instance of URLRequestResult. Throws if there is an error.
    func sendDataWith(request: URLRequest) async throws -> URLRequestResult {
        if TestsRouter.interceptForMocking {
            if let result = TestsRouter.sendTestRequest(request: request) {
                return result
            }
        }

        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<URLRequestResult, Error>) in
            URLSession.logRequest(request)
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let result = URLRequestResult(request: request, response: response, data: data)
                URLSession.logResult(result)
                continuation.resume(returning: result)
            }

            task.resume()
        })
    }

    // MARK: - Record calls
    private static  func logRequest(_ request: URLRequest) {
        if NetworkCallLogger.recordCalls {
            NetworkCallLogger.shared.logRequest(request)
        }
    }

    private static func logResult(_ result: URLRequestResult) {
        if NetworkCallLogger.recordCalls {
            NetworkCallLogger.shared.logResult(result)
        }

        sendMaintainanceModeNotificationIfNeeded(result)
    }

    private static func sendMaintainanceModeNotificationIfNeeded(_ result: URLRequestResult) {
        if !result.serviceIsInMaintainanceMode { return }

        DispatchQueue.main.async {
            guard let data = result.data else {
                NotificationCenter.default.post(name: NSNotification.Name.BackendDidGoIntoMaintainanceMode,
                                                object: nil)
                return
            }

            let decoder = JSONDecoder()

            do {
                let decoded = try decoder.decode(ErrorMetaDataModel.self, from: data)
                if let maintainanceMode = decoded.response.maintenanceMode {
                    if maintainanceMode {
                        NotificationCenter.default.post(name: NSNotification.Name.BackendDidGoIntoMaintainanceMode,
                                                        object: decoded)
                    }
                    else {
                        SharedLogger.shared.logMessage(tag: "URLSessionAsyncExtensions", message: "503 Error. No maintainance mode set to false")
                    }
                }
                else {
                    SharedLogger.shared.logMessage(tag: "URLSessionAsyncExtensions", message: "503 Error. No maintainance mode")
                }


            } catch {
                SharedLogger.shared.logMessage(tag: "URLSessionAsyncExtensions", message: "Error json is unexpected")
                NotificationCenter.default.post(name: NSNotification.Name.BackendDidGoIntoMaintainanceMode,
                                                object: nil)
            }
        }
    }
}
