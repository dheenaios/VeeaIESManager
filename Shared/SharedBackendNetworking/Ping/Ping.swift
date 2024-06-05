//
//  Ping.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/07/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation
import SwiftyPing


/// A simple ping implementation. Pings only once.
/// Do not use directly. Use PingProtocol.newPing
class Ping: PingProtocol {
    var pingState: PingState
    var host: String

    required public init(hostName: String) {
        pingState = .waiting
        host = hostName
    }

    func sendPing(stateChange: @escaping((PingState) -> Void)) {
        guard let once = try? SwiftyPing(host: host,
                                         configuration: PingConfiguration(interval: 0.5, with: 5),
                                         queue: DispatchQueue.global()) else {
            self.pingState = .pingDidFail
            stateChange(.pingDidFail)
            return
        }
        
        once.observer = { (response) in
            if let pingError = response.error {
                if pingError == .responseTimeout {
                    self.pingState = .pingDidTimeOut
                    stateChange(.pingDidTimeOut)

                }
                else {
                    self.pingState = .pingDidFail
                    stateChange(.pingDidFail)
                }

                return
            }

            self.pingState = .pingDidSucceed
            stateChange(.pingDidSucceed)
        }

        once.targetCount = 1

        do {
            try once.startPinging()
            self.pingState = .pinging
        }
        catch {
            self.pingState = .pingDidFail
            stateChange(.pingDidFail)
        }
    }
}
