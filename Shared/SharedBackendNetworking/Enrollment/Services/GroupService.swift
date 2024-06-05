//
//  GroupService.swift
//  VeeaHub Manager
//
//  Created by Bajirao Bhosale on 15/06/21.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

fileprivate enum GroupEndpoint {
    case groupDetails(String)
    
    var value: String {
        var path = ""
        switch self {
        case .groupDetails(let groupIds):
            path = "/groupservice/api/v2/groups/\(groupIds)"
        }
        return _GroupEndPoint(path)
    }
}


public class GroupService {
    public class func getGroupDetailsForCurrentUser(success: @escaping (_ groups: [GroupsModel]) -> Void, error: @escaping ErrorCallback) {
        do {
            let groupIds = UserSessionManager.shared.allGroupIds
            let url = GroupEndpoint.groupDetails(groupIds.joined(separator: ",")).value
            let request = try VKHTTPRequest.create(url: url)
            try VKHTTPManager.call(request: request, requireResponseKey : false, result: { (rStatus, rData, rError) in
                if let groups = VKDecoder.decode(type: [GroupsModel].self, data: rData) {
                    if rStatus {
                        success(groups)
                        return
                    }
                }
                error(VKHTTPManagerError.parseError(error: rError))

                if let rError = rError {
                    if rError.code == VKHTTPManagerError.updateRequired.code {
                        UpdateManager.shared.showUpdateRequiredPopUp()
                    }
                }
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }
}
