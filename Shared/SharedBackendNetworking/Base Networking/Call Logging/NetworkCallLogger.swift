//
//  NetworkCallLogger.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 18/08/2022.
//

import Foundation

public struct NetworkCallLoggerItem: Hashable {
    public static func == (lhs: NetworkCallLoggerItem, rhs: NetworkCallLoggerItem) -> Bool {
        lhs.id == rhs.id
    }

    private let id = UUID()
    public private(set) var created: Date
    public private(set) var request: URLRequest?
    public private(set)var result: URLRequestResult?

    public var send: Bool {
        result == nil ? true : false
    }

    public var url: String {
        if let requestUrl = request?.url {
            return "\(requestUrl)"
        }
        if let result = result {
            if let requestUrl = result.request.url {
                return "\(requestUrl)"
            }
        }

        return "Unknown"
    }

    public var httpMethod: String {
        if let request = request {
            return request.httpMethod ?? "Unknown 1"
        }
        if let result = result {
            return result.request.httpMethod ?? "Unknown 2"
        }

        return "Unknown 3"
    }

    public var headers: [String] {
        var headerStrings = [String]()
        var request = request
        if let result = result {
            request = result.request
        }

        guard let request = request,
              let headers = request.allHTTPHeaderFields else {
            return headerStrings
        }

        for (key, value) in headers {
            headerStrings.append("\(key): \(value)")
        }

        return headerStrings
    }

    public var summaryRows: [String] {
        var rows = [String]()
        if let request = request {
            if let url = request.url {
                rows.append("URL: \(url)")
            }
            else {
                rows.append("URL Unknown")
            }

            rows.append("Created: \(DateFormatter.shortDateTime.string(from: created))")
            return rows
        }

        if let result = result {

            if let url = result.request.url {
                rows.append("URL: \(url)")
            }
            else {
                rows.append("URL Unknown")
            }
            rows.append("Method: \(httpMethod)")
            rows.append("HTTP Code: \(result.httpCode)")
            rows.append("Created: \(DateFormatter.shortDateTimeWithSeconds.string(from: created))")
            return rows
        }

        return rows
    }

    public var logText: String {
        if send {
            guard let request = request else {
                return "Request get Error"
            }

            return getSummaryFor(request: request)
        }
        else {
            guard let result = result else {
                return "Result get Error"
            }

            return getSummaryFor(result: result) + "\n\n"
        }
    }

    private func getSummaryFor(request: URLRequest) -> String {
        let sent = DateFormatter.iso8601Full.string(from: created)
        var urlStr = "Unknown URL"
        if let url = request.url {
            urlStr = url.absoluteString
        }

        let method = request.httpMethod ?? "Unknown method"
        let headers = "\(String(describing: request.allHTTPHeaderFields))"
        let body = request.httpBody?.prettyPrintedString ?? ""

        var text = String()

        text.append("\n\n- \(sent)\n-\(urlStr)\n-\(method)")
        text.append("\n\n- Headers...\n" + headers + "\n\n- Body..." + body)

        return text
    }

    private func getSummaryFor(result: URLRequestResult) -> String {
        let request = "### Request...\n\(getSummaryFor(request: result.request))\n\n"

        let httpCode = result.httpCode
        let responseBody = result.prettyPrintedData

        let response = "Response...\n\(getSummaryFor(request: result.request))\n\n" + "- HTTP Code...\n \(httpCode)\n\n" + "- Body...\n\(responseBody)"

        let text = request + response

        return text
    }

    public init(request: URLRequest?, result: URLRequestResult?) {
        self.request = request
        self.result = result
        self.created = Date()
    }
}

public class NetworkCallLogger {
    public static var recordCalls: Bool {
        get {
            if ApplicationTargets.current == .QA {
                return _recordCalls
            }

            return false
        }
        set {
            _recordCalls = newValue
            if !_recordCalls {
                NetworkCallLogger.shared.clearAll()
            }
        }
    }

    @SharedUserDefaultsBacked(key: "_recordNetworkCalls",
                        defaultValue: false)
    public static var _recordCalls: Bool

    public static var shared = NetworkCallLogger()

    public private(set) var requests = [NetworkCallLoggerItem]()
    public private(set) var results = [NetworkCallLoggerItem]()

    public var reversedRequests: [NetworkCallLoggerItem] {
        return requests.reversed()
    }

    public var reversedResults: [NetworkCallLoggerItem] {
        return results.reversed()
    }

    public func clearAll() {
        requests = [NetworkCallLoggerItem]()
        results = [NetworkCallLoggerItem]()
    }

    func logRequest(_ request: URLRequest) {
        requests.append(NetworkCallLoggerItem(request: request, result: nil))
    }

    func logResult(_ result: URLRequestResult) {
        results.append(NetworkCallLoggerItem(request: nil, result: result))
    }
}

