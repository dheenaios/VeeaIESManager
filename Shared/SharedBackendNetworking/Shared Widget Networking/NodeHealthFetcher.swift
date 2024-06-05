//
//  NodeHealthFetcher.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 21/06/2022.
//

import Foundation

public class NodeHealthFetcher {
    let tag = "NodeHealthFetcher"
    let manager = DeviceOptionsManager()

    private(set) var nodeModels: [NodeModel]?
    private(set) var healthModels: [HubHealth]?
    private var widgetHubIds: [String]? // Ids to fetch


    /// Gets the nodee models from the mesh. Then gets the health state of those models from the MAS
    /// These are processed and returned as DeviceHealthSummary models
    /// - Parameters:
    ///   - widgetHubIds: the hub ids from the widget
    ///   - completion: An Array of DeviceHealthSummaries and an optional error string
    public func fetchNodeHealthStates(widgetHubIds: [String], completion: @escaping ([DeviceHealthSummary], String?) -> Void) {

        // Set up the auth manager each time we make a call in order to pull in the latest from the app
        // as the token may have changed in the main app if the user logs in and out
        AuthorisationManager.shared.setup()

        Log.tag(tag: "NodeHealthFetcher", message: "Starting health states fetch")
        Log.tag(tag: "NodeHealthFetcher", message: "Widget IDs are: \(widgetHubIds)")
        Log.tag(tag: "NodeHealthFetcher", message: "Getting mesh / node info")

        self.widgetHubIds = widgetHubIds
        manager.getDevices { models, error  in // Details of the nodes in the mesh
            if let error = error {
                Log.tag(tag: "NodeHealthFetcher", message: "Getting mesh / node info finished with error \(error)")
                completion([DeviceHealthSummary](), error)
                return
            }


            Log.tag(tag: "NodeHealthFetcher", message: "Getting mesh / node info finished successfully. Got \(models.count)")
            Log.tag(tag: "NodeHealthFetcher", message: "Moving on to get the hub health info from the MAS")
            self.nodeModels = models

            self.fetchHealthFor(nodes: models) { health, errorMessage  in // The health data
                self.healthModels = health

                Log.tag(tag: "NodeHealthFetcher", message: "Got health models. Error = \(errorMessage ?? "no error")")

                guard health != nil else {
                    completion([DeviceHealthSummary](), errorMessage)
                    return
                }

                let summaries = self.generateHealthSummaries()
                Log.tag(tag: "NodeHealthFetcher", message: "Got health summaries... \(summaries)")
                completion(summaries, errorMessage)
            }
        }
    }


    /// Gets hub health info
    /// - Parameters:
    ///   - nodes: The nodes we wantto get the health for
    ///   - completion: The health models and an optional error messsage
    private func fetchHealthFor(nodes: [NodeModel], completion: @escaping(([HubHealth]?, String?) -> Void)) {
        let ids = nodes.map{ $0.id }
        guard let ids = ids as? [String],
              let token = AuthorisationManager.shared.formattedAuthToken else {
            completion(nil, "Could not get token")

            return
        }

        let call = MasApiHubHealthCall()
        call.makeCallWith(token: token,
                          serials: ids) { SuccessAndOptionalMessage in
            if SuccessAndOptionalMessage.0 {
                completion(call.hubHealth, nil)
            }
            else {
                completion(call.hubHealth, SuccessAndOptionalMessage.1)
            }
        }
    }

    public init(){}
}

extension NodeHealthFetcher {
    private func generateHealthSummaries() -> [DeviceHealthSummary] {
        var summaries = [DeviceHealthSummary]()

        guard let nodeModels = nodeModels,
              let healthModels = healthModels else {
            return summaries
        }

        for nodeModel in nodeModels {
            var found = false
            for healthModel in healthModels {
                if nodeModel.id == healthModel.UnitSerial {
                    if widgetHubIds!.contains(nodeModel.id) {
                        summaries.append(generateSummary(nodeModel: nodeModel,
                                                         healthModel: healthModel))
                        found = true
                    }
                }
            }

            // If the health state is not found, this is probably because the hub has not yet enrolled
            if !found {
                summaries.append(generateSummary(nodeModel: nodeModel,
                                                 healthModel: nil))
            }
        }

        return summaries
    }

    private func generateSummary (nodeModel: NodeModel,
                                  healthModel: HubHealth?) -> DeviceHealthSummary{
        var state = NodeHealthState.healthy
        let status = nodeModel.status

        if status != .ready {
            state = .installing
        }

        if status == .error {
            state = .errors
        }

        if status == .bootstrapping  || (nodeModel.status == .ready && healthModel == nil) {
            state = .installing
            return DeviceHealthSummary(deviceId: nodeModel.id,
                                       deviceName: nodeModel.name,
                                       state: state)
        }

        if let healthModel = healthModel {
            if !healthModel.Connected {
                state = .offline
                return DeviceHealthSummary(deviceId: nodeModel.id,
                                           deviceName: nodeModel.name,
                                           state: state)
            }

            if healthModel.NodeState.RebootRequired {
                state = .needsReboot
                return DeviceHealthSummary(deviceId: nodeModel.id,
                                           deviceName: nodeModel.name,
                                           state: state)
            }
            else if !healthModel.NodeState.Healthy {
                state = .errors
                return DeviceHealthSummary(deviceId: nodeModel.id,
                                           deviceName: nodeModel.name,
                                           state: state)
            }
        }

        return DeviceHealthSummary(deviceId: nodeModel.id,
                                   deviceName: nodeModel.name,
                                   state: state)
    }
}

public struct DeviceHealthSummary {
    public let deviceId: String
    public let deviceName: String
    public let state: NodeHealthState
}
