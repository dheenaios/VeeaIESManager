//
//  RebootCommand.swift
//  IESManager
//
//  Created by Richard Stockdale on 31/05/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

struct PowerCommands {

    /// Reboot a given VeeaHub. Remember to nil the current hub and disconnect from the wifi if nessesary
    /// - Parameter completed: Success, and a user information message
    static func restart(hub: HubConnectionDefinition?, completed: @escaping (Bool, String) -> Void) {
        guard let hub = hub,
              var config = HubDataModel.shared.baseDataModel?.nodeControlConfig else {
            completed(false, "No hub connected".localized())
            return
        }

        config.setRebootTrigger()
        ApiFactory.api.setConfig(connection: hub, config: config) { (result, error) in
            if let error = error {
                completed(false, error.localizedDescription)
                return
            }
            // Show shutting down message
            completed(true, "Restarting & disconnecting".localized())
        }
    }

    static func shutdown(hub: HubConnectionDefinition?, completed: @escaping (Bool, String) -> Void) {

        guard let hub = hub,
              var config = HubDataModel.shared.baseDataModel?.nodeControlConfig else {
            completed(false, "No hub connected".localized())
            return
        }

        config.setShutdownTrigger()
        ApiFactory.api.setConfig(connection: hub, config: config) { (result, error) in
            if let error = error {
                completed(false, error.localizedDescription)
                return
            }
            // Show shutting down message
            completed(true, "Disconnecting & shutting down\nThis can take a few minutes".localized())
        }
    }
}
