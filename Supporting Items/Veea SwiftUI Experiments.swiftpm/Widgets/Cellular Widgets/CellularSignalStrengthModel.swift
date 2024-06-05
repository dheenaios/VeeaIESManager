import SwiftUI

struct CellularSignalStrengthModel {
    let networkType: String // 3G / 4G / 5G
    let carrierName: String
    let signalStrengthBars: Int // 0 - 5
}
