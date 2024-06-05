//
//  ConnectivityMonitor.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 14/07/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import Network
import SharedBackendNetworking

// See also VKReachabilityManager.
//
protocol InternetConnectionStatusChangedDelegate: AnyObject {
    func connectivityStateChanged(state: InternetConnectionMonitor.InternetConnectivityStatus)
}

class InternetConnectionMonitor {
    
    public enum InternetConnectivityStatus {
        case Disconnected, ConnectedToInternet
    }
    
    public weak var delegate: InternetConnectionStatusChangedDelegate?
    
    static let shared = InternetConnectionMonitor()
    private let monitor = NWPathMonitor()
    private var ping: PingProtocol?
    private var status: NWPath.Status = .requiresConnection
    private var timer: Timer?

    /// Current state
    var connectivityStatus: InternetConnectivityStatus = .ConnectedToInternet {
        didSet {
            Logger.log(tag: "InternetConnectionMonitor",
                       message: "Connection status changed: \(connectivityStatus)")
        }
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if self?.status == path.status { return }
                self?.status = path.status
                self?.pingInternet()
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)

        if timer != nil { return }
        self.timer = Timer.scheduledTimer(withTimeInterval: 20.0,
                                          repeats: true,
                                          block: { timer in
            self.pingInternet()
        })
    }
    
    private func sendNotification() {
        delegate?.connectivityStateChanged(state: connectivityStatus)
        NotificationCenter.default.post(name: NSNotification.Name.NetworkStateDidChange,
                                        object: nil)
    }
    
    func stopMonitoring() {
        monitor.cancel()
        timer?.invalidate()
        timer = nil
    }
    
    private func pingInternet() {

        self.ping = PingFactory.newPing(hostName: "8.8.8.8")
        self.ping?.sendPing { state in
            var newState = self.connectivityStatus

            switch state {
            case .pingDidSucceed:
                newState = .ConnectedToInternet
            case .pingDidFail, .pingDidTimeOut:
                newState = .Disconnected
            case .waiting, .pinging:
                return
            }

            if newState != self.connectivityStatus {

                // The ping has been seen to fail sometimes if on proxys
                // If it fails, then check we really are disconnected.
                if newState != .ConnectedToInternet {
                    self.checkEndPointAvailable()
                }
                else {
                    self.connectivityStatus = newState
                    self.sendNotification()
                }
            }
        }
    }

    private func checkEndPointAvailable() {
        Task {
            let check = MaintainanceModeCheck()
            let available = await check.isEndpointAvailable()
            self.connectivityStatus = available ? .ConnectedToInternet : .Disconnected

            await MainActor.run {
                self.sendNotification()
            }
        }
    }
}
