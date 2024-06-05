//
//  AnalyticsEventProtocol.swift
//  IESManager
//
//  Created by Richard Stockdale on 26/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

// https://firebase.blog/posts/2020/08/google-analytics-manual-screen-view
public protocol AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames { get }
}

extension AnalyticsScreenViewEventProtocol {
    var screenClass: String {
        String(describing: type(of: self))
    }

    func recordScreenAppear() {
        AnalyticsEventHelper.logScreenEvent(screenName: screenName,
                                            screenClass: screenClass)
    }
}
