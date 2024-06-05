//
//  TimeConfigViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


// MARKED FOR DELETION ON 5 August 2020.
// Remove if no objections

class TimeConfigViewModel: BaseConfigViewModel {
    
    private var updatedTime: String?
    
    private var iesInfo: NodeInfo? = {
        return HubDataModel.shared.baseDataModel?.nodeInfoConfig
    }()
    
    var nodeTime: String {
        guard  let c = iesInfo else {
            return "Unknown".localized()
        }
        
        guard let updatedTime = updatedTime else {
            return Utils.localTimeStringFromUTC(string: c.node_time)
        }
        
        return updatedTime
    }
    
    var restartTime: String {
        guard  let c = iesInfo else {
            return "Unknown".localized()
        }
        
        return c.reboot_time  // restart time is NOT returned as UTC!
    }
    
    var restartReason: String {
        guard  let c = iesInfo else {
            return ""
        }
        
        return c.reboot_reason
    }
    
    func refreshTime(completion: @escaping CompletionDelegate) {
        guard let h = connectedHub else {
            let message = "Not connected to a VeeaHub".localized()
            completion(message, APIError.Failed(message: message))
            return
        }
        
        ApiFactory.api.refreshTime(connection: h) { (ok, error) in
            if let time = ok {
                self.updatedTime = time.node_time
                completion(nil, nil)
                return
            }
            
            completion(nil, error)
        }
    }
    
}
