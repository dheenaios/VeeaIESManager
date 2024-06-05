//
//  IntentHandler.swift
//  HealthWidgetIntentHandler
//
//  Created by Richard Stockdale on 15/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Intents
import SharedBackendNetworking

class IntentHandler: INExtension {

    private func getDevices() -> [VeeaHub] {
        let nodes = DeviceOptionsManager.cachedDeviceDetails

        var veeaHubs = [VeeaHub]()
        for node in nodes {
            let veeaHub = VeeaHub(identifier: node.id, display: node.name, pronunciationHint: nil)
            veeaHubs.append(veeaHub)
        }

        return veeaHubs
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
}

extension IntentHandler: SelectHubIntentHandling {
    func provideParameterOptionsCollection(for intent: SelectHubIntent,
                                           with completion: @escaping (INObjectCollection<VeeaHub>?, Error?) -> Void) {
        let collection = INObjectCollection(items: getDevices())
        completion(collection, nil)
    }
}
