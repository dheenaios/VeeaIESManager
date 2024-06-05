//
//  APRadioConfigTableViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 22/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class APRadioConfigTableViewModel: BaseConfigViewModel {
    
    private lazy var vmeshConfig: VmeshConfig! = {
        return HubDataModel.shared.baseDataModel?.vmeshConfig
    }()
    
    public var config = HubDataModel.shared.baseDataModel?.nodeConfig
    public var nodeCapabilityconfig = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig
    public let automaticSelectionOptionString = "Auto Selection".localized()
    public let disabledOptionString = "Disabled".localized()

    
    public var initialAccessChannelSetting: String? {
        get {
            if let c = HubDataModel.shared.baseDataModel?.nodeConfig {
                let acs = selectedFreq == .AP1 ? c.access1_acs : c.access2_acs
                if acs {
                    return automaticSelectionOptionString
                }
                
                let v = selectedFreq == .AP1 ? c.access1_channel : c.access2_channel
                return "\(v)"
            }
            
            return nil
        }
    }
    
    // MARK: - Static Info
    
    // Segues
    let whiteListSegueId = "whiteList"
    
    // Bandwidth
    let bandwidth20 = "20"
    let bandwidth40 = "20/40"
    let bandwidth80 = "20/40/80"
    
    // AP1 Whitelist channels
    var ap1WhiteListOptions: [Int] {
        get {
            return config?.access1_allowed_whitelist_chans ?? [Int]()
        }
    }
    
    var ap2WhiteListOptions: [Int] {
        get {
            return config?.access2_allowed_whitelist_chans ?? [Int]()
        }
    }
    
    var updatedWhiteListChannels: [Int]?
    
    // Table View
    struct RowID {
        static let operationChannel = 0
        static let operationChannelPicker = 1
        static let accessChannel = 2
        static let accessChannelPicker = 3
        static let actualChannel = 4
        static let excludeDfs = 5
        static let whiteList = 6
        static let scan = 7
        static let accessBandwidth = 8
        static let actualBandwidth = 9
        static let useLowerBand = 10
        static let accessMode = 11
        static let disable802_11ax = 12
        static let maxStations = 13
        static let maxInactivity = 14
        static let transmitPower = 15
        static let transmitPowerPicker = 16
    }
    
    // MARK: - Dynamic info
    
    public var currentChannel: String?
    public var currentOperation: SelectedOperation?

    
    public var selectedFreq: SelectedAP = .AP1 {
        didSet {
            currentChannel = selectedAccessChannel
        }
    }
    
    
    /// Get the index for the mode selector from the access mode string in node config
    /// - Parameter accessMode: the access mode string
    /// - Returns: the index of the selected segment
    public func segmentedControllerIndexFrom(accessMode: String) -> Int {
        //Possible option strings are "mixed" and "nac_only"
        if accessMode.lowercased().contains(NodeConfig.accessModeMixedVal) {
            return 0
        }
        
        return 1
    }
    
    
    /// The inverse of segmentedControllerIndexFrom(). Get the string value to send to the api from the index
    /// - Parameter selectedIndex: the selected index
    /// - Returns: the api value
    public func accessModeFromSegmentedControllerIndex(selectedIndex: Int) -> String {
        //Possible option strings are "mixed" and "nac_only"
        if selectedIndex == 0 {
            return NodeConfig.accessModeMixedVal
        }
        
        return NodeConfig.accessModeNACVal
    }
    
    public var isCurrentChannelAuto: Bool {
        return currentChannel == automaticSelectionOptionString
    }
    
    var hasAcs: Bool {
        guard let cap = HubDataModel.shared
            .baseDataModel?
            .nodeCapabilitiesConfig else {
                return false
        }
        
        let acsAvailable = selectedFreq == .AP1 ? cap.ap1AcsSupport : cap.ap2AcsSupport
        return acsAvailable
    }
    
    var acsIsOn: Bool {
        if !hasAcs {
            return false
        }
        
        let acsIsOn = selectedFreq == .AP1 ? config?.access1_acs : config?.access2_acs
        return acsIsOn ?? false
    }
    
    var showActualChannel: Bool {
        if let config = config {
            if HubDataModel
                .shared
                .hardwareVersion
                .isvhe09AndAp2(isAp2: selectedFreq == .AP2) {
                if !HubDataModel.shared.hasVmeshLockedFromVmeshLocalControl() {
                    return false
                }
            }
            
            let actual = selectedFreq == .AP1 ? config.access1_channel_actual : config.access2_channel_actual
            
            return actual == -1 ? false : true
        }
        
        return false
    }
    
    var showDfsChannels: Bool {
        guard let cap = HubDataModel
            .shared
            .baseDataModel?
            .nodeCapabilitiesConfig else {
            return false
        }
        
        let unii1AndDfsCh = selectedFreq == .AP1 ? cap.unii1AndDfsCh_Ap1 : cap.unii1AndDfsCh_Ap2
        
        if !unii1AndDfsCh {
            return false
        }
        
        if isCurrentChannelAuto && selectedFreq == .AP2 {
            return showActualChannel
        }
        
        return false
    }
    
    var showWhiteList: Bool {
        if HubDataModel
            .shared
            .hardwareVersion
            .isvhe09AndAp2(isAp2: selectedFreq == .AP2) {
            if !HubDataModel.shared.hasVmeshLockedFromVmeshLocalControl() {
                return false
            }
        }
        
        if hasAcs || selectedFreq == .AP2 {
            return true
        }
        
        return false
    }

    var isAp2MeshRadio: Bool {
        if selectedFreq == .AP1 {
            return false
        }
        
        let hasMultiRadio = HubDataModel.shared
        .baseDataModel?
        .nodeCapabilitiesConfig?
        .ap2Charateristics?
        .meshRadio ?? false
        
        return hasMultiRadio
    }
    
    var showBandwidthOptions: Bool {
        if selectedFreq == .AP1 && isCurrentChannelAuto {
            return false
        }
        
        return true
    }
    
    // MARK: - ACS Values
    
    var selectedApChannelActual: String {
        get {
            if selectedFreq == .AP1 {
                return "\(config?.access1_channel_actual ?? -1)"
            }
            
            return "\(config?.access2_channel_actual ?? -1)"
        }
    }
    
    var selectedApChannelOptions: [String] {
        var channelsStrArray = [String]()
        guard let config = config else {
            return channelsStrArray
        }
        
        let channels = selectedFreq == .AP1 ? config.access1_wifi_channels : config.access2_wifi_channels
        
        if hasAcs {
            channelsStrArray.append(automaticSelectionOptionString)
        }
        
        for channel in channels {
            channelsStrArray.append("\(channel)")
        }
        
        return channelsStrArray
    }
    
    var selectedApOperationOptions: [String] {
        var channelsStrArray = [String]()
        channelsStrArray = ["Start Access Point","Disabled"]
        return channelsStrArray
    }
    var selectedOperationChannel: String {
        if currentOperation == .Disabled {
            return "Disabled"
        }else{
            return "Start Access Point"
        }
    }
    
    /// Returns the selected access channel.
    /// If its set to auto the auto string will be returned
    /// If not the selected channel will be returned
    var selectedAccessChannel: String {
        let selected = selectedFreq == .AP1 ? config?.access1_channel : config?.access2_channel
        
        if hasAcs {
            let acsSelected = (selectedFreq == .AP1 ? config?.access1_acs : config?.access2_acs) ?? false
            if acsSelected {
                return automaticSelectionOptionString
            }
        }
        
        return "\(selected ?? -1)"
    }
    
    var showScanOption: Bool {
        if HubDataModel
            .shared
            .hardwareVersion
            .isvhe09AndAp2(isAp2: selectedFreq == .AP2) {
            if !HubDataModel.shared.hasVmeshLockedFromVmeshLocalControl() {
                return false
            }
        }
        
        return hasAcs
    }
    
    var access1Show802_11axOption: Bool {
        guard let config = config,
              let _ = config.access1_80211ax,
              let chars = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.ap1Charateristics else {
                  // If the fields are not present, then we do not show
                  return false
              }
        
        return chars.accessSupports801_22ax
    }
    
    var access2Show802_11axOption: Bool {
        guard let config = config,
              let _ = config.access2_80211ax,
              let chars = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.ap2Charateristics else {
                  // If the fields are not present, then we do not show
                  return false
              }
        
        return chars.accessSupports801_22ax
    }
}

// MARK: - ACS Whitelist
extension APRadioConfigTableViewModel {
    // Channels that have been white listed for the selected AP
    var whiteListedChannels: [Int] {
        get {
            if updatedWhiteListChannels != nil {
                return updatedWhiteListChannels!
            }
            
            guard let c = config else {
                return [Int]()
            }
            
            let selectedWhiteListChannels = selectedFreq == .AP1 ? c.access1_auto_select_channels : c.access2_auto_select_channels
            return selectedWhiteListChannels
        }
        set {
            updatedWhiteListChannels = newValue
        }
    }
    
    var haveWhiteListChannelsChanged: Bool {
        guard let c = config else {
            return false
        }
        
        let selectedWhiteListChannels = selectedFreq == .AP1 ? c.access1_auto_select_channels : c.access2_auto_select_channels
        
        return updatedWhiteListChannels != selectedWhiteListChannels
    }
    
    func whiteListOptions() -> [PickerItem] {
        var items = [PickerItem]()

        let channels = selectedFreq == .AP1 ? ap1WhiteListOptions : ap2WhiteListOptions
        
        for value in channels {
            let ticked = whiteListedChannels.contains(value) ? true : false
            items.append(PickerItem(title: "\(value)", isTicked: ticked))
        }
        
        return items
    }
}

// MARK: - Updating
extension APRadioConfigTableViewModel {
    
    
    /// Updates the access channel and returns bool indicating if there has been a change
    /// - Parameter selectionText: The text description of the channel. Taken from the picker selection
    /// - Returns: If there has been an update
    func hasAccessChannelChanged(selectionText: String?) -> Bool {
        
        // There are 3 types of changes here...
        // 1. Moving from manual to auto
        // 2. Moving from auto to manual
        // 3. Moving from Manual to Manual
        
        guard let selectionText = selectionText else {
            return false
        }
        
        // 1. Check if we have selected automatic, set the accessXAcs to true
        let acsState = (selectedFreq == .AP1 ? config?.access1_acs : config?.access2_acs) ?? true
        if selectionText == automaticSelectionOptionString && !acsState{
            if selectedFreq == .AP1 {
                config?.access1_acs = true
            }
            else {
                config?.access2_acs = true
            }
            
            return true
        }
        
        // 2. If the setting was auto and the new setting is manual
        if acsState && selectionText != automaticSelectionOptionString {
            if selectedFreq == .AP1 {
                config?.access1_acs = false
                
                if let channel = Int(selectionText) {
                    config?.access1_channel = channel
                }
            }
            else {
                config?.access2_acs = false
                if let channel = Int(selectionText) {
                    config?.access2_channel = channel
                }
            }
            
            return true
        }
        
        // 3. If we are switching from manual channel to manual channel
        if let v = Int(selectionText) {
            if selectedFreq == .AP1 {
                if v != config?.access1_channel {
                    config?.access1_channel = v
                    config?.access1_acs = false
                    
                    return true
                }
            }
            else {
                if v != config?.access2_channel {
                    config?.access2_channel = v
                    config?.access2_acs = false
                    
                    return true
                }
            }
        }
        
        
        return false
    }
}

// MARK: - VHM 1346 - Show / hide channel configuration
extension APRadioConfigTableViewModel {
    // VHM 1348 - Show hide channel configuration
    var showChannelConfigurationOption: Bool {
        
        // If not 5Ghz, then we show
        if selectedFreq == .AP1 { return true }
        
        guard let nodeCapabilities = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig,
              let ap2Charateristics = nodeCapabilities.ap2Charateristics else {
            return false
        }
        
        // if no vmesh capability then we show
        if !nodeCapabilities.hasVmeshCapability { return true }
        
        // Do we have mesh radio?
        if ap2Charateristics.meshRadio { return showChannelConfigForMeshRadioAvailable }
        
        // If no mesh radio we can show the channel
        return true
    }
    
    private var showChannelConfigForMeshRadioAvailable: Bool {
        guard let vmeshConfig = HubDataModel.shared.baseDataModel?.vmeshConfig else {
            return true
        }
        
        let localControl = VmeshConfig.WanOperationalOption.fromString(str: vmeshConfig.vmesh_local_control)
        
        switch localControl {
        case .disabled: // Locked
            return true
        case .auto:
            return showForVmeshLocalControlAuto
        case .join:
            return false
        case .start:
            return false
        }
    }
    
    private var showForVmeshLocalControlAuto: Bool {
        guard let mode = HubDataModel.shared.baseDataModel?.nodeStatusConfig?.vmeshOperatingMode else {
            return false
        }
        
        switch mode {
        case .wiredOnly:
            return true
        case .wirelessStart:
            return false
        case .wirelessJoin:
            return false
        }
    }
    
    var showOperation: Bool {
       guard let nodeCapConfig = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig else {
           return false
       }
       
       if selectedFreq == .AP1 {
           return nodeCapConfig.hasOperationFor2GHZ
       }
       
       return nodeCapConfig.hasOperationFor5GHZ
   }
   //Check the Ooperation Value when landing on the screen first time
   var currentOperationSelected: SelectedOperation? {
      guard let nodeConfig = HubDataModel.shared.baseDataModel?.nodeConfig else {
          return .Start
      }
       if selectedFreq == .AP1 {
           if nodeConfig.access1_local_control?.lowercased() == "locked" {
              return .Disabled
          }
       }else{
           if nodeConfig.access2_local_control?.lowercased() == "locked" {
              return .Disabled
          }
       }

      return .Start
  }
}
