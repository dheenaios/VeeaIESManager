//
//  BaseConfigViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 10/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


public class BaseConfigViewModel {
    
    public typealias CompletionDelegate = (String?, APIError?) -> Void
    
    /// Base Data Model. May return nil
    public var bdm: HubBaseDataModel? {
        return HubDataModel.shared.baseDataModel
    }
    
    /// Optional Data Model. May return nil
    public var odm: OptionalAppsDataModel? {
        return HubDataModel.shared.optionalAppDetails
    }
    
    /// Connected Veea Hub. May return nil if nothing is connected
    public var connectedHub: HubConnectionDefinition? {
        return HubDataModel.shared.connectedVeeaHub
    }
    
    public var isMN: Bool {
        return HubDataModel.shared.isMN
    }

    // MARK: - Updating

    // MARK: - Update observer. Call observer() to tell the view to update
    private var observer: ((ViewModelUpdateType?) -> Void)?

    func addAsObserver(observer: @escaping ((ViewModelUpdateType?) -> Void)) {
        self.observer = observer
    }

    func informObserversOfChange(type: ViewModelUpdateType?) {
        guard let o = observer else { return }
        o(type)
    }
}
