//
//  TestsRouter.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 25/07/2022.
//

import Foundation

// Known calls
fileprivate enum Calls: String {
    case unknown
}

public class TestsRouter {
    private struct MasHostEndPoints {
        private static let hostQA = "qa.veea.co"
        private static let hostRelease = "dweb.veea.co"

        static func isHost(host: String) -> Bool {
            if host == hostQA { return true }
            else if host == hostRelease { return true }
            return false
        }

        static let groupServiceGroups = "groupservice/api/v2/groups/"
        static let meshesAndProcessingHubs = "enrollment/enroll/" // Meshes and processing hubs (with processing as last url component)
        static let meshDetails = "enrollment/mesh"
    }

    private struct AuthHostEndPoints {
        private static let hostQA = "qa-auth.veea.co"
        private static let hostRelease = "auth.veea.co"

        static func isHost(host: String) -> Bool {
            if host == hostQA { return true }
            else if host == hostRelease { return true }
            return false
        }

        static let authTokenRequest = "auth/realms/veea/protocol/openid-connect/token"
        static let userInfo = "auth/realms/veea/protocol/openid-connect/userinfo"
        static let realms = "auth/realms/veea/veearealms/realms"
    }

    // MARK: - Test conditionals

    public static var interceptForMocking: Bool {
        return !interceptOnlyInTests || testRunning
    }

    /// Set this to false to always intercept calls
    private static let interceptOnlyInTests = true

    private static var testRunning: Bool {
#if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return true
        }
#endif

        return false
    }

    // MARK: - Mocking

    static func sendTestRequest(request: URLRequest) -> URLRequestResult? {
        return handleRequest(request)
    }

    private static func handleRequest(_ request: URLRequest) -> URLRequestResult? {
        guard let mockedResponse = getMockedResponse(request) else {
            return nil
        }

        let result = URLRequestResult.mockedURLRequestResult(request: request,
                                                             data: mockedResponse.data,
                                                             httpCode: mockedResponse.httpCode)

        return result
    }

    private static func getMockedResponse(_ request: URLRequest) -> MockResponses.MockRequestResponse? {
        guard let url = request.url,
              let host = url.host else {
            return nil
        }

        if AuthHostEndPoints.isHost(host: host) {
            return handleAuthHostRequests(request: request)
        }
        else if MasHostEndPoints.isHost(host: host) {
            return handleMasRequests(request: request)
        }

        // Return nil if unknown
        return nil
    }

    private static func response(response: MockResponses.Responses) -> MockResponses.MockRequestResponse? {
        do {
            return try MockResponses.load(response: response)
        }
        catch {
            //print("Error getting mock response for \(response.rawValue)... \(error)")
            return nil
        }
    }
}

// MARK: - Auth Calls
extension TestsRouter {
    private static func handleAuthHostRequests(request: URLRequest) -> MockResponses.MockRequestResponse? {
        guard let urlString = request.url?.absoluteString else { return nil }

        var mock: MockResponses.MockRequestResponse?

        if urlString.contains(AuthHostEndPoints.authTokenRequest) {
            mock = response(response: .postAuthTokenResponse)
        }
        else if urlString.contains(AuthHostEndPoints.userInfo) {
            mock = response(response: .getUserInfo)
        }
        else if urlString.contains(AuthHostEndPoints.realms) {
            mock = response(response: .getRealms)
        }

        if mock == nil {
            //print("No mock for \(request.url?.absoluteString ?? "Unknown")")
        }

        return mock
    }
}

// MARK: - MAS Calls
extension TestsRouter {
    private static func handleMasRequests(request: URLRequest) -> MockResponses.MockRequestResponse? {
        guard let urlString = request.url?.absoluteString else { return nil }

        var mock: MockResponses.MockRequestResponse?
        if urlString.contains(MasHostEndPoints.groupServiceGroups) {
            mock = response(response: .getGroups)
        }
        else if urlString.contains(MasHostEndPoints.meshesAndProcessingHubs) {
            guard let components = request.url?.pathComponents else {
                return nil
            }
            let last = components.last
            if last == "processing" {
                mock = response(response: .getProcessingHubs)
            }
            else {
                mock = response(response: .getMeshes)
            }

            // Processing. Last


        }
        else if urlString.contains(MasHostEndPoints.meshDetails) {
            mock = response(response: .getMeshDetails)
        }

        if mock == nil {
            //print("No mock for \(request.url?.absoluteString ?? "Unknown")")
        }

        return mock
    }
}
