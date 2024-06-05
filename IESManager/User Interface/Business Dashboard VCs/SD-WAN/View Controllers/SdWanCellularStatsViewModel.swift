//
//  SdWanCellularStatsViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 08/07/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking


public class SdWanCellularStatsViewModel: BaseConfigViewModel {
    
    let config: CellularDataStatsConfig
    var bytesSent = [ConfigRow]()
    var bytesReceived = [ConfigRow]()
    var billing = [ConfigRow]()
    
    let sectionTitles = ["Sent".localized(), "Received".localized()]
    
    override init() {
        config = HubDataModel.shared.optionalAppDetails!.cellularDataStatsConfig!
        
        // SENT
        bytesSent.append(ConfigRow.init(title: "Today".localized(), value: config.bytes_sent_current_day, isBytes: true))
        bytesSent.append(ConfigRow.init(title: "Yesterday".localized(), value: config.bytes_sent_previous_day, isBytes: true))
        bytesSent.append(ConfigRow.init(title: "This month".localized(), value: config.bytes_sent_current_month, isBytes: true))
        bytesSent.append(ConfigRow.init(title: "Last month".localized(), value: config.bytes_sent_previous_month, isBytes: true))
        
        // RECEIVED
        bytesReceived.append(ConfigRow.init(title: "Today".localized(), value: config.bytes_recv_current_day, isBytes: true))
        bytesReceived.append(ConfigRow.init(title: "Yesterday".localized(), value: config.bytes_recv_previous_day, isBytes: true))
        bytesReceived.append(ConfigRow.init(title: "This month".localized(), value: config.bytes_recv_current_month, isBytes: true))
        bytesReceived.append(ConfigRow.init(title: "Last month".localized(), value: config.bytes_recv_previous_month, isBytes: true))
    }
    
    public struct ConfigRow {
        public let mTitle: String
        private var mIntValue: UInt64?
        private var mStringValue: String?
        
        public let mIsBytes: Bool
        
        public var value: String {
            get {
                if mIntValue != nil {
                    return formattedIntValue()
                }
                
                if let value = mStringValue {
                    return value
                }
                
                return ""
            }
        }
        
        // MARK: - Conversions
        private func formattedIntValue() -> String {
            if mIsBytes {
                let converter = DataUnitConverter(bytes: Int64(mIntValue!))
                
                return converter.getReadableUnit()
            }
            
            if let value = mIntValue {
                return "\(value)"
            }
            
            return ""
        }
        
        // MARK: - INIT
        public init(title: String, value: UInt64, isBytes: Bool) {
            mTitle = title
            mIntValue = value
            mIsBytes = isBytes
        }
        
        public init(title: String, value: String, isBytes: Bool) {
            mTitle = title
            mStringValue = value
            mIsBytes = isBytes
        }
    }
}
