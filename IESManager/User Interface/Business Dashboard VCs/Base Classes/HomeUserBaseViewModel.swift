//
//  HomeUserBaseViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 16/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

class HomeUserBaseViewModel: BaseConfigViewModel {
    
    var masConnection: MasConnection? {
        return HubDataModel.shared.connectedVeeaHub as? MasConnection
    }
    
    func sendConfig(config: ApiRequestConfigProtocol) {
        guard let masConnection = masConnection else {
            return
        }
        
        ApiFactory.api.setConfig(connection: masConnection,
                                 config: config) { message, error in
            if let error = error {
                self.informObserversOfChange(type: .sendingDataFailed(error.localizedDescription))
                return
            }
            
            // Refresh the data model
            HubDataModel.shared.updateConfigInfo { success, progress, message in
                if progress == 1 {
                    if success {
                        self.informObserversOfChange(type: .sendingDataSuccess)
                    }
                    else {
                        self.informObserversOfChange(type: .sendingDataFailed(message ?? "Something went wrong. Please try again."))
                    }
                }
            }
        }
    }


    /// Sends the config, but returns a success callback instead of informing the observers
    /// - Parameter config: Config
    func sendConfigWithCallback(config: ApiRequestConfigProtocol, completion: @escaping(Bool) -> Void) {
        guard let masConnection = masConnection else {
            return
        }

        ApiFactory.api.setConfig(connection: masConnection,
                                 config: config) { message, error in
            if let error = error {
                self.informObserversOfChange(type: .sendingDataFailed(error.localizedDescription))
                return
            }

            // Refresh the data model
            HubDataModel.shared.updateConfigInfo { success, progress, message in
                completion(success)
            }
        }
    }
}
