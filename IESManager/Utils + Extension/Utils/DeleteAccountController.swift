//
//  DeleteAccountController.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class DeleteAccountController {
    private var sending = false
    
    func deleteAccount() async -> Bool {
        sending = true
        return await makeDeleteCall()
    }
    
    private func makeDeleteCall() async -> Bool {
        // https://qa.veea.co/enrollment/account/remove
        let url = _GroupEndPoint("/enrollment/account/remove")
        
        let request = await RequestFactory.authenticatedRequest(url: url,
                                                                method: "POST",
                                                                body: nil)
        sending = true
        
        do {
            let result = try await URLSession.sendDataWith(request: request)
            sending = false
            return result.isHttpResponseGood
        }
        catch {
            sending = false
            return false
        }
    }
}
