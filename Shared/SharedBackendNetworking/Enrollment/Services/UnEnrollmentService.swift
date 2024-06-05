//
//  UnEnrollmentService.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 09/03/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class UnEnrollmentService {
    private static let path = "/enroll/device/"
    
    class func unEnroll(node: VHMeshNode, success: @escaping (SuccessAndOptionalMessage) -> Void) {
        guard let id = node.id else {
            return
        }
        
        do {
            let url = _AppEndpoint(path + id)
            let request  = try VKHTTPRequest.create(url: url, type: .delete, data: nil)
            
            try VKHTTPManager.call(request: request, result: { (status, rData, rError) in
                success((status, rError?.localizedDescription))
            })
        }
        catch let e {
            success((false, e.localizedDescription))
        }
    }
}
