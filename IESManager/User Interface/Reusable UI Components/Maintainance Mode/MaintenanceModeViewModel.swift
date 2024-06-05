//
//  MaintenanceModeViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 01/09/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking
import UIKit

@MainActor class MaintenanceModeViewModel: ObservableObject {

    private let updatePeriod: TimeInterval = 120
    private var timer: Timer?
    private var checker = MaintainanceModeCheck()

    @Published var isInMaintMode = true
    @Published var checking = false

    init() {
        startTimer()
    }

    var retryButtonOpacity: Double {
        return checking ? 0.3 : 1.0
    }

    func check() {
        checking = true
        Task {
            isInMaintMode = await checker.isInMaintainanceMode()
            checking = false

            if !isInMaintMode {
                stopTimer()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showLoginFlowCoordinator()

            }
        }
    }

    private func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: updatePeriod,
                                          repeats: true,
                                          block: { timer in
            self.check()
        })
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
