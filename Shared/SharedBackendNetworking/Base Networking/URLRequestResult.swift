//
//  URLRequestResult.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 18/08/2022.
//

import Foundation

public struct URLRequestResult: Hashable {
    public private(set) var creationDate = Date()
    public private(set) var request: URLRequest
    public private(set) var response: URLResponse?
    public var data: Data?

    public private(set) var httpCode = 0

    init(request: URLRequest, response: URLResponse?, data: Data?) {
        self.request = request
        self.data = data
        self.response = response

        let httpResponse = response as? HTTPURLResponse
        httpCode = httpResponse?.statusCode ?? 0
    }

    /// Is the response in the 200 range?
    public var isHttpResponseGood: Bool {
        return httpCode >= 200 && httpCode < 300
    }
    
    public var prettyPrintedData: String {
        guard let data = data else {
            return "No data"
        }

        if let str = data.prettyPrintedString {
            return str
        }

        return "Could not parse data to a string"
    }

    static func mockedURLRequestResult(request: URLRequest, data: Data?, httpCode: Int) -> URLRequestResult {
        var r = URLRequestResult(request: request, response: URLResponse(), data: data)
        r.httpCode = httpCode

        return r
    }
}

// MARK: - Maintainance mode
// See VHM-1500 and... https://veea.atlassian.net/wiki/spaces/DEV/pages/304212574209/Control+Center+VHM+Maintenance+Page
public extension URLRequestResult {
    var serviceIsInMaintainanceMode: Bool {
        httpCode == 503
    }
}
