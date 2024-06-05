//
//  HomeWifiAps.swift
//  IESManager
//
//  Created by Richard Stockdale on 25/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

// Helper methods to get wifi aps
struct HomeWifiAps {

    // MARK: - 2.4Ghz Aps
    lazy var primaryAp: AccessPointConfig = {
        // The guest AP will the the first non system AP
        for ap in HubDataModel.shared.baseDataModel!.meshAPConfig!.aps2ghz {
            if !ap.system_only {
                return ap
            }
        }

        return HubDataModel.shared.baseDataModel!.meshAPConfig!.ap_1_3 // We should never reach here
    }()

    lazy var guestAp: AccessPointConfig = {
        // The guest AP will the the second non system AP
        var firstUserApFound = false

        for ap in HubDataModel.shared.baseDataModel!.meshAPConfig!.aps2ghz {
            if !ap.system_only {
                if !firstUserApFound {
                    firstUserApFound = true
                    continue
                }

                return ap
            }
        }

        return HubDataModel.shared.baseDataModel!.meshAPConfig!.ap_1_4 // We should never reach here
    }()

    lazy var primaryApIndex: Int = {
        for (index, ap) in HubDataModel.shared.baseDataModel!.meshAPConfig!.aps2ghz.enumerated() {
            if !ap.system_only {
                return index
            }
        }

        return 2
    }()

    lazy var guestApIndex: Int = {
        // The guest AP will the the second non system AP
        var firstUserApFound = false

        for (index, ap) in HubDataModel.shared.baseDataModel!.meshAPConfig!.aps2ghz.enumerated() {
            if !ap.system_only {
                if !firstUserApFound {
                    firstUserApFound = true
                    continue
                }

                return index
            }
        }

        return 3
    }()

    // MARK: - 5Ghz Aps
    lazy var primaryAp5Ghz: AccessPointConfig = {
        // The guest AP will the the first non system AP
        for ap in HubDataModel.shared.baseDataModel!.meshAPConfig!.aps5ghz {
            if !ap.system_only {
                return ap
            }
        }

        return HubDataModel.shared.baseDataModel!.meshAPConfig!.ap_2_3 // We should never reach here
    }()

    lazy var guestAp5Ghz: AccessPointConfig = {
        // The guest AP will the the second non system AP
        var firstUserApFound = false

        for ap in HubDataModel.shared.baseDataModel!.meshAPConfig!.aps5ghz {
            if !ap.system_only {
                if !firstUserApFound {
                    firstUserApFound = true
                    continue
                }

                return ap
            }
        }

        return HubDataModel.shared.baseDataModel!.meshAPConfig!.ap_2_4 // We should never reach here
    }()

    lazy var primaryAp5GhzIndex: Int = {
        for (index, ap) in HubDataModel.shared.baseDataModel!.meshAPConfig!.aps5ghz.enumerated() {
            if !ap.system_only {
                return index
            }
        }

        return 2
    }()

    lazy var guestAp5GhzIndex: Int = {
        // The guest AP will the the second non system AP
        var firstUserApFound = false

        for (index, ap) in HubDataModel.shared.baseDataModel!.meshAPConfig!.aps5ghz.enumerated() {
            if !ap.system_only {
                if !firstUserApFound {
                    firstUserApFound = true
                    continue
                }

                return index
            }
        }

        return 3
    }()

    // MARK: - Same
    // The 2.4Ghz and 5Ghz Wi-Fi SSID and Passwords should be the same for the home setup
    // This can be changed in the enterprise dashboard.
    // If they are different they cannot use the home settings and need to go to the enterprise UI
    var is2GhzAnd5GhzDetailsSame: Bool {
        mutating get {
            return is2GhzAnd5GhzPrimaryDetailsSame &&
            is2GhzAnd5GhzGuestDetailsSame
        }
    }

    private var is2GhzAnd5GhzPrimaryDetailsSame: Bool {
        mutating get {
            return primaryAp.ssid == primaryAp5Ghz.ssid &&
            primaryAp.pass == primaryAp5Ghz.pass &&
            primaryAp.enabled == primaryAp5Ghz.enabled

        }
    }

    private var is2GhzAnd5GhzGuestDetailsSame: Bool {
        mutating get {
            return guestAp.ssid == guestAp5Ghz.ssid &&
            guestAp.pass == guestAp5Ghz.pass &&
            guestAp.enabled == guestAp5Ghz.enabled
        }
    }
}
