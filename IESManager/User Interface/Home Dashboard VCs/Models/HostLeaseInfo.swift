//
//  HostLeaseInfo.swift
//  IESManager
//
//  Created by Richard Stockdale on 23/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

/*
 
// See...
// https://mas.dev.veeaplatform.net/api/docs/v2#operation/VMeshes

The current implementation if for the home version of the app. It assumed one group. One vmesh.
Changes will be needed if this is to be applied to the enterprise version of the app.
 
 */
 
class HostLeaseInfo {
    
    let base = BackEndEnvironment.masApiBaseUrl
    private var updateHandler: (() -> Void)?
    
    private var vmeshes: [Vmesh]? {
        didSet {
            getLeaseDetails()
        }
    }
    
    var leases: LeaseDetails?
    var errorObject: ErrorObject?
    
    /// For use in home user situations as they only have one group
    func leasesForGroupAndMesh(updated: @escaping () -> Void) {
        updateHandler = updated
        getVmeshDetails()
    }
    
    private func getVmeshDetails() {
        // Get all the Vmeshes... because I cant get the individual group call to work
        
        let urlString = "https://\(base)/api/v2/vmeshes" // e.g... "https://qamas.veea.io/api/v2/vmeshes"
        let r = request(url: urlString)

        URLSession.sendDataWith(request: r) { result, error in
            guard let data = result.data else {
                self.errorObject = ErrorObject(success: false, message: "Error getting vmesh details")
                self.notifyOfUpdate()

                return
            }


            if let vmeshes = VKDecoder.decode(type: [Vmesh].self, data: data) {
                self.vmeshes = vmeshes
                return
            }

            self.errorObject = ErrorObject(success: false, message: "Error parsing vmesh details")
            self.notifyOfUpdate()
        }
    }
    
    private func getLeaseDetails() {
        //https://mas.dev.veeaplatform.net/api/docs/v2#operation/GetDevices
        guard let vmeshId = vmeshes?.first?.id else {
            // TODO: Handle this
            return
        }
        
        let urlString = "https://\(base)/api/v2/vmeshes/\(vmeshId)/devices" // e.g... "https://qamas.veea.io/api/v2/vmeshes/33484/devices"
        let r = request(url: urlString)

        URLSession.sendDataWith(request: r) { result, error in
            guard let data = result.data else {
                self.errorObject = ErrorObject(success: false, message: "Error getting lease details")
                self.notifyOfUpdate()
                return
            }

            if let leases = VKDecoder.decode(type: LeaseDetails.self, data: data) {
                self.errorObject = nil
                self.leases = leases

                self.notifyOfUpdate()
                return
            }
            if let errorObject = VKDecoder.decode(type: ErrorObject.self, data: data) {
                self.errorObject = errorObject
                self.leases = nil

                self.notifyOfUpdate()
                return
            }

            self.errorObject = ErrorObject(success: false, message: "Error getting lease details from Backend")
            self.notifyOfUpdate()
        }
    }
    
    private func notifyOfUpdate() {
        if let updateHandler = updateHandler {
            DispatchQueue.main.async {
                updateHandler()
            }
        }
    }
    
    private func request(url: String) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!, timeoutInterval: Double.infinity)
        request.addValue(AuthorisationManager.shared.formattedAuthToken!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
}

struct Vmesh: Codable {
    let id: Int
    let createdAt: String
    let updatedAt: String
    let groupId: Int
    let name: String
    let ssid: String
    let swarmID: String
    let restrictedBackhaulOperational: Bool
    let analyticsEnabled: Bool
    let analyticsInterval: Int
    let uuid: String
    let lastSeenPost: String
    let lastSeenPoll: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case groupId = "GroupId"
        case name = "Name"
        case ssid = "SSID"
        case swarmID = "SwarmID"
        case restrictedBackhaulOperational = "RestrictedBackhaulOperational"
        case analyticsEnabled = "AnalyticsEnabled"
        case analyticsInterval = "AnalyticsInterval"
        case uuid = "UUID"
        case lastSeenPost = "LastSeenPost"
        case lastSeenPoll = "LastSeenPoll"
    }
}

struct ErrorObject: Codable {
    let success: Bool
    let message: String
}

struct LeaseDetails: Codable {
    let timestamp: Int
    let leases: [Lease]
    
    var numberOfLeases: Int {
        // May need to review this.
        // Only return leases that are in date
        return leases.count
    }
    
    var timeStampDate: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    enum CodingKeys: String, CodingKey {
        case timestamp = "Timestamp"
        case leases = "Leases"
    }
}

struct Lease: Codable {
    let clientID: String
    let l2Overlay: String
    let macAddress: String
    let expiry: Int
    let ipAddress: String
    let hostName: String
    
    var expiryDate: Date {
        Date(timeIntervalSince1970: TimeInterval(expiry))
    }
    
    enum CodingKeys: String, CodingKey {
        case clientID = "ClientID"
        case l2Overlay = "L2Overlay"
        case macAddress = "MACAddress"
        case expiry = "Expiry"
        case ipAddress = "IPAddress"
        case hostName = "HostName"
    }
}
