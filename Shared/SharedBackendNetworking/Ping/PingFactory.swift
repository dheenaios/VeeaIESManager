//
//  PingFactory.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/07/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

/*
 VHM-1652
 Use the factory and the protocol to abstract the ping implimentation to
 allow us to swap it out in the future if nessesary.
 Currenly used ping lib is https://github.com/samiyr/SwiftyPing
 */

public struct PingFactory {
    public static func newPing(hostName: String) -> PingProtocol {
        return Ping(hostName: hostName)
    }
}

public enum PingState {
    case waiting
    case pinging
    case pingDidFail
    case pingDidTimeOut
    case pingDidSucceed

    public func description() -> String {
        switch self {
        case .pingDidFail:
            return "Failed"
        case .pingDidTimeOut:
            return "Timed out"
        case .pingDidSucceed:
            return "Success"
        case .pinging:
            return "Pinging"
        case .waiting:
            return "Waiting"
        }
    }
}

// An interface for simple ping functionality.
// Use this as a way to swap out ping libs in future
public protocol PingProtocol: AnyObject {
    init(hostName: String)

    var host: String { get }

    /// Returns the ping state of an error (timed out failed) or success.
    /// - Parameter stateChange: The result ping state
    func sendPing(stateChange: @escaping((PingState) -> Void))

    /// The current state of the ping
    var pingState: PingState { get }
}


