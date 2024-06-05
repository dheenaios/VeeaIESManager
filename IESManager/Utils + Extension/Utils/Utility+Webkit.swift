//
//  Utility+Webkit.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 3/15/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import WebKit

class WebCacheCleaner {
    
    class func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
//        VKLog("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
//                VKLog("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
}
