//
//  ExternalLaunchController.swift
//  IESManager
//
//  Created by Richard Stockdale on 10/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation


/// Class for handling launches from notifications (remote and background) and widget taps
class ExternalLaunchController {
    
    var isLoggedIn: Bool {
        // TODO:
        return true
    }
    
    func jumpToMesh(mesh: String, in group: String) {
        
    }
    
    func jumpToGroup(group: String) {
        
    }
}

/*
 
 ## Group ID
 cdaf1bd3-bd00-46f6-b599-a81b45ea5777

 ## Mesh ID
 1d2c15f0-e7a1-4824-8ade-a8f214792dd1

 ## Loud
 {
    "aps" : {
       "alert" : {
          "title" : "Test Push",
          "subtitle" : "Test push notification",
          "body" : "Push payload body"
          "target" : {
              groupId : "cdaf1bd3-bd00-46f6-b599-a81b45ea5777"
              meshId : "1d2c15f0-e7a1-4824-8ade-a8f214792dd1"
          }
       }

    }
 }

 ## Silent
 {
   "aps": {
     "content-available": 1
   }
 }

 
 */
