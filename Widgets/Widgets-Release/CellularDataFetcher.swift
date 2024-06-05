//
//  CellularDataFetcher.swift
//  IESManager
//
//  Created by Richard Stockdale on 11/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class CellularDataFetcher {

    typealias Callback = () -> Void
    private var callBack: Callback!

    private var men: NodeModel!
    private var connection: MasConnection!
    private lazy var decoder = JSONDecoder()

    private var cellStats: CellularStats?
    private var cellUsageStats: CellularDataStats?

    public enum CellularState {
        case notLoaded
        case allGood
        case noSubscription
        case somethingWentWrong(String)
    }

    private(set) var cellularState: CellularState = .notLoaded {
        didSet {
            callBack()
        }
    }

    func getCellularDetails(callBack: @escaping Callback) {
        self.callBack = callBack
        guard let men = DeviceOptionsManager.getCachedMen else {
            cellularState = .somethingWentWrong("Could not load VeeaHubDetails")
            return // Need to handle this in the  widget view
        }

        self.men = men

        // Set up the auth manager each time we make a call in order to pull in the latest from the app
        // as the token may have changed in the main app if the user logs in and out
        AuthorisationManager.shared.setup()

        if AuthorisationManager.shared.tokenExpired {
            AuthorisationManager.shared.accessToken { newToken in
                self.getConnection()
            }
        }
        else {
            getConnection()
        }
    }

    private func getConnection() {
        // Get a connection
        MasConnectionFactory.makeMasConectionFor(nodeSerial: men.id) { success, connection in
            guard let connection = connection else {
                self.cellularState = .somethingWentWrong("Could not make a connection to the MAS")
                return
            }

            self.connection = connection
            self.makeCellularCalls()
        }
    }

    func makeCellularCalls() {
        let signalStrengthCall = MasSingleTableGet(masConnection: connection, tableName: "node_metrics")
        signalStrengthCall.makeCall { [self] response in
            guard let data = response.data else {
                self.cellularState = .somethingWentWrong("Could not get Signal Data")
                return // TODO:
            }

            do {
                let decoder = JSONDecoder()
                self.cellStats = try decoder.decode(CellularStats.self, from: data)
                self.checkForCompletion()
            }
            catch {
                // This should always return, even if there is no cellular capability
                self.cellularState = .somethingWentWrong("Signal Data was in an unexpected format")


            }
        }

        let cellularStatsCall = MasSingleTableGet(masConnection: connection, tableName: "cellular_data_count")
        cellularStatsCall.makeCall { response in
            guard let data = response.data else {
                self.cellularState = .somethingWentWrong("Could not load Usage Data")
                return
            }

            do {
                let decoder = JSONDecoder()
                self.cellUsageStats = try decoder.decode(CellularDataStats.self, from: data)
                self.checkForCompletion()
            }
            catch {
                // This will fail if there is no usage data
                self.cellularState = .noSubscription
            }
        }
    }

    private func checkForCompletion() {
        if cellStats != nil && cellUsageStats != nil {
            cellularState = .allGood
        }
    }
}

// MARK: - Signal Strength
extension CellularDataFetcher {
    var networkMode: String {
        guard let cellStats = cellStats else {
            return ""
        }

        return cellStats.network_mode
    }

    var carrierName: String {
        guard let cellStats = cellStats else {
            return ""
        }

        return cellStats.network_operator
    }

    var signalStrength: Int {
        guard let cellStats = cellStats else {
            return 0
        }

        return CellularStrengthToBars.convert(strengthPercentage: cellStats.signal_level)
    }
}

// MARK: - Usage
extension CellularDataFetcher {

    var todayUp: String {
        guard let u = cellUsageStats else { return "-" }
        let converter = DataUnitConverter(bytes: Int64(u.bytes_sent_current_day))
        return converter.shortReadableUnit()
    }

    var todayDown: String {
        guard let u = cellUsageStats else { return "-" }
        let converter = DataUnitConverter(bytes: Int64(u.bytes_recv_current_day))
        return converter.shortReadableUnit()
    }

    var yesterdayUp: String {
        guard let u = cellUsageStats else { return "-" }
        let converter = DataUnitConverter(bytes: Int64(u.bytes_sent_previous_day))
        return converter.shortReadableUnit()
    }

    var yesterdayDown: String {
        guard let u = cellUsageStats else { return "-" }
        let converter = DataUnitConverter(bytes: Int64(u.bytes_recv_previous_day))
        return converter.shortReadableUnit()
    }

    var thisMonthUp: String {
        guard let u = cellUsageStats else { return "-" }
        let converter = DataUnitConverter(bytes: Int64(u.bytes_sent_current_month))
        return converter.shortReadableUnit()
    }

    var thisMonthDown: String {
        guard let u = cellUsageStats else { return "-" }
        let converter = DataUnitConverter(bytes: Int64(u.bytes_recv_current_month))
        return converter.shortReadableUnit()
    }

    var lastMonthUp: String {
        guard let u = cellUsageStats else { return "-" }
        let converter = DataUnitConverter(bytes: Int64(u.bytes_sent_previous_month))
        return converter.shortReadableUnit()
    }

    var lastMonthDown: String {
        guard let u = cellUsageStats else { return "-" }
        let converter = DataUnitConverter(bytes: Int64(u.bytes_recv_previous_month))
        return converter.shortReadableUnit()
    }

}
