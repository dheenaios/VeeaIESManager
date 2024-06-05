//
//  CellularDataStatsConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 08/07/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public struct CellularDataStatsConfig: TopLevelJSONResponse, Codable {
    
    var originalJson: JSON = JSON()
    
    @DecodableDefault.Int64Zero var cellular_data_count: UInt64 = 0

    @DecodableDefault.Int64Zero var bytes_sent: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_sent_current_day: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_recv_previous_day: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_sent_current_month: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_sent_previous_month: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_sent_previous: UInt64 = 0

    @DecodableDefault.Int64Zero var bytes_recv: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_recv_current_day: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_sent_previous_day: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_recv_current_month: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_recv_previous_month: UInt64 = 0
    @DecodableDefault.Int64Zero var bytes_recv_previous: UInt64 = 0

    @DecodableDefault.Int64Zero var current_day: UInt64 = 0
    
    @DecodableDefault.Zero var billing_day: Int = 0
    @DecodableDefault.Zero var month_of_last_calculation: Int = 0
    @DecodableDefault.Zero var month_next_bill_point: Int = 0

    @DecodableDefault.False var lock_database: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case cellular_data_count,
             bytes_sent_current_day,
             bytes_sent_current_month,
             bytes_recv_current_day,
             bytes_sent_previous_month,
             bytes_sent,
             month_of_last_calculation,
             bytes_recv_previous,
             bytes_sent_previous,
             current_day,
             bytes_sent_previous_day,
             month_next_bill_point,
             bytes_recv_previous_month,
             bytes_recv_previous_day,
             bytes_recv,
             bytes_recv_current_month,
             lock_database,
             billing_day
    }
    
    static func getTableName() -> String {
        return DbCellularDataCount.TableName
    }
}
