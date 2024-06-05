//
//  DbCellularDataCount.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 02/07/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct DbCellularDataCount: DbSchemaProtocol {
    static var TableName = "cellular_data_count"
    
    static var Cellular_data_count = "cellular_data_count"
    static var Bytes_sent_current_day = "bytes_sent_current_day"
    static var Bytes_sent_current_month = "bytes_sent_current_month"
    static var Bytes_recv_current_day = "bytes_recv_current_day"
    static var Bytes_sent_previous_month = "bytes_sent_previous_month"
    static var Bytes_sent = "bytes_sent"
    static var Month_of_last_calculation = "month_of_last_calculation"
    static var Bytes_recv_previous = "bytes_recv_previous"
    static var Bytes_sent_previous = "bytes_sent_previous"
    static var Current_day = "current_day"
    static var Bytes_sent_previous_day = "bytes_sent_previous_day"
    static var Month_next_bill_point = "month_next_bill_point"
    static var Bytes_recv_previous_month = "bytes_recv_previous_month"
    static var Bytes_recv_previous_day = "bytes_recv_previous_day"
    static var Bytes_recv = "bytes_recv"
    static var Bytes_recv_current_month = "bytes_recv_current_month"
    static var Lock_database = "lock_database"
    static var Billing_day = "billing_day"

    


}
