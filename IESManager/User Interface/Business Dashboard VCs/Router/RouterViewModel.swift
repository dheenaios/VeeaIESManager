//
//  RouterViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class RouterViewModel: BaseConfigViewModel {
    var routerConfig: RouterConfig? = {
        return HubDataModel.shared.baseDataModel?.routerConfig
    }()
    
    var acceptListChanged = false
    var denyListChanged = false
    
    var acceptMacList: [String]? {
        get {
            return routerConfig?.access_accept_mac_list
        }
        set {
            guard let newValues = newValue, sameContents(arr1: newValue!, arr2: acceptMacList!) == false else {
                return
            }
            
            routerConfig?.access_accept_mac_list = newValues
            acceptListChanged = true
        }
    }
    
    var denyMacList: [String]? {
        get {
            return routerConfig?.access_deny_mac_list
        }
        set {
            guard let newValues = newValue, sameContents(arr1: newValue!, arr2: denyMacList!) == false else {
                return
            }
            
            routerConfig?.access_deny_mac_list = newValues
            denyListChanged = true
        }
    }
    
    private func sameContents(arr1: [String], arr2: [String]) -> Bool {
        if arr1.count != arr2.count {
            return false
        }
        
        for (index, string) in arr1.enumerated() {
            let string2 = arr2[index]
            
            if string != string2 {
                return false
            }
        }
        
        return true
    }
    
    func applyUpdate(completion: @escaping CompletionDelegate) {
        guard let h = connectedHub else {
            return
        }
        
        ApiFactory.api.setConfig(connection: h, config: routerConfig!) { (result, error) in
            completion(nil, error)
        }
    }
}
