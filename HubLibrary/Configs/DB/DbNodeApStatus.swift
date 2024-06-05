//
//  DbNodeApStatus.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 27/01/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

struct DbNodeApStatus: DbSchemaProtocol {
    static var TableName = "node_ap_status"
    
    // TOP LEVEL OBJECTS
    static let AP1 = "ap1"
    static let AP_1_1 = "ap_1_1"
    static let AP_1_2 = "ap_1_2"
    static let AP_1_3 = "ap_1_3"
    static let AP_1_4 = "ap_1_4"
    static let AP_1_5 = "ap_1_5"
    static let AP_1_6 = "ap_1_6"
    static let AP2 = "ap2"
    static let AP_2_1 = "ap_2_1"
    static let AP_2_2 = "ap_2_2"
    static let AP_2_3 = "ap_2_3"
    static let AP_2_4 = "ap_2_4"
    static let AP_2_5 = "ap_2_5"
    static let AP_2_6 = "ap_2_6"
    
    // apx
    static let FITTED = "fitted"
    static let BSSID = "bssid"
    
    // ap_x_x
    static let TIMESTAMP = "timestamp"
    
    // Common
    static let MAC = "mac"
    static let OPSTATE = "opstate"
}

/*
 Bit of an unusual format for this one.
 
 {
   "node_ap_status" : {
     "ap2" : {
       "fitted" : true,
       "bssid" : "02:19:70:c3:ba:f0",
       "mac" : "00:19:70:c3:ba:fe",
       "opstate" : true
     },
     "ap_2_3" : {
       "mac" : "0a:19:70:c3:ba:fe",
       "opstate" : true,
       "timestamp" : 1611567260
     },
     "ap_2_5" : {
       "mac" : "unknown",
       "opstate" : false,
       "timestamp" : 0
     },
     "ap_2_2" : {
       "mac" : "06:19:70:c3:ba:fe",
       "opstate" : true,
       "timestamp" : 1611567260
     },
     "ap_2_4" : {
       "mac" : "unknown",
       "opstate" : false,
       "timestamp" : 0
     },
     "ap1" : {
       "fitted" : true,
       "bssid" : "02:19:70:c3:b4:20",
       "mac" : "00:19:70:c3:b4:2b",
       "opstate" : true
     },
     "ap_2_1" : {
       "mac" : "00:19:70:c3:ba:fe",
       "opstate" : true,
       "timestamp" : 1611567260
     },
     "ap_1_5" : {
       "mac" : "unknown",
       "opstate" : false,
       "timestamp" : 0
     },
     "_rev" : "146-15523210d46cfe5d9476f6f13cf808f5",
     "ap_1_4" : {
       "mac" : "unknown",
       "opstate" : false,
       "timestamp" : 0
     },
     "ap_1_1" : {
       "mac" : "00:19:70:c3:b4:2b",
       "opstate" : true,
       "timestamp" : 1611567259
     },
     "ap_1_2" : {
       "mac" : "06:19:70:c3:b4:2b",
       "opstate" : true,
       "timestamp" : 1611567259
     },
     "ap_2_6" : {
       "mac" : "unknown",
       "opstate" : false,
       "timestamp" : 0
     },
     "ap_1_3" : {
       "mac" : "0a:19:70:c3:b4:2b",
       "opstate" : true,
       "timestamp" : 1611567260
     },
     "ap_1_6" : {
       "mac" : "unknown",
       "opstate" : false,
       "timestamp" : 0
     },
     "_id" : "01c00091031df31e0706"
   }
 }
 
 */
