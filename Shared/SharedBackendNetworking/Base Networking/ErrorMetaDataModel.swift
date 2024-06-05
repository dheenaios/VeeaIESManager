//
//  ErrorMetaDataModel.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 02/09/2022.
//

import Foundation

public struct ErrorMetaDataModel: Codable {
    public let meta: Meta
    public let response: Response

    public struct Response: Codable {
        public let title: String
        public let message: String
        public var maintenanceMode: Bool?
    }
}


/*

 {
   "meta": {
     "status": 503,
     "message": "Test - maintenance"
   },
   "response": {
     "title": "Custom Title - Our Apologies",
     "message": "Custom Message - Due to ongoing maintenance, Control Center is currently not available"
   }
 }




 */
