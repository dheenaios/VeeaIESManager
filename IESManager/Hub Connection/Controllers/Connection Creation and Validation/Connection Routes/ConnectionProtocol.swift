//
//  ConnectionProtocol.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 20/08/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


public enum HubConnectionState {
    case NOT_STARTED
    case IN_PROGRESS
    case STOPPED
    case SUCCEDED
    case FAILED
}

/// Callback used by the ConnectionProtocol to inform the host of progress
public protocol ConnectionProgressProtocol {
    
    /// Returns if there is an issue with the VeeaHub passed in
    ///
    /// - Parameter errorMessage: Error message
    func errorWithVeeaHub(errorMessage: String)
    
    /// Returns when the connection attempt starts
    ///
    ///   - connectionRoute: The route the callback relates to
    func connectionAttemptStarted(connectionRoute: ConnectionProtocol)
    
    
    /// Returns when the LAN is validated. For Hub APs this is called after the connection
    /// is complete and the IPs are validated.
    ///
    /// - Parameters:
    ///   - success: Success or fail
    ///   - failMessage: An optional message. Nil unless the connection failed
    ///   - connectionRoute: The route the callback relates to
    func networkConnectionValidated(success: Bool, message: String?, connectionRoute: ConnectionProtocol)
    
    /// Called when the test ping is complete
    ///
    /// - Parameters:
    ///   - success: Was the mobile device able to ping the hub
    ///   - failMessage: An optional message. Nil unless the ping failed
    ///   - connectionRoute: The route the callback relates to
    func testPingResult(success: Bool, failMessage: String?, connectionRoute: ConnectionProtocol)
    
    /// Called when the Data model get is complete
    ///
    /// - Parameters:
    ///   - success: Was the data model download as expected
    ///   - failMessage: An optional message. Nil unless the model get failed
    ///   - connectionRoute: The route the callback relates to
    func getHubDataModelComplete(success: Bool, failMessage: String?, connectionRoute: ConnectionProtocol)
}

/// A protocol defining methods required for creating a connection to a hub
/// The implementing class is responsible creation and testing of the connection
public protocol ConnectionProtocol {
    
    /// The type of connection
    var connectionType: ConnectionRoute { get set }
    
    /// The current state of connection
    var connectionState: HubConnectionState { get set }
    
    /// Callback
    var delegate: ConnectionProgressProtocol { get set }
    
    /// The hub being connected too
    var connectionDefinition: HubConnectionDefinition { get set }
    
    /// Init the object
    ///
    /// - Parameters:
    ///   - hub: The hub to be connected
    ///   - connectionType: The type of connection
    ///   - delegate: A callback to receive progress on the connection
    init?(hub: HubConnectionDefinition,
          connectionType: ConnectionRoute,
          progressDelegate: ConnectionProgressProtocol)
    
    /// Start the connection attempt
    func startConnectionAttempt()
    
    /// Called to stop the connection attempt
    func stopConnectionAttempt()
}
