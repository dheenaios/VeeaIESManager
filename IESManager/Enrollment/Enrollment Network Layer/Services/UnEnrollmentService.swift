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
    public typealias SuccessAndOptionalMessageWithMetaData = (Bool, String?, ErrorHandlingData?)

    class func unEnroll(node: VHMeshNode, success: @escaping (SuccessAndOptionalMessageWithMetaData) -> Void) {
        guard let id = node.id else {
            return
        }
        
        do {
            let url = _AppEndpoint(path + id)
            let request  = try VKHTTPRequest.create(url: url, type: .delete, data: nil)
            
            try VKHTTPManager.call(request: request, result: { (status, rData, rError, errorData) in
                success((status, rError?.localizedDescription, errorData))
            })
        }
        catch let e {
            success((false, e.localizedDescription, nil))
        }
    }
}
