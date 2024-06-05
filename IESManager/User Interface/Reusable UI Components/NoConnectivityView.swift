//
//  NoConnectivityView.swift
//  IESManager
//
//  Created by Richard Stockdale on 29/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct NoConnectivityView: View {
    private let titleText = "No Internet Connection"
    private let subTitleText = "Slow or no internet connection"
    private let actionText = "Please check your internet connection"

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image("No Connection-Red")
                .resizable()
                .frame(width: 75, height: 56)
            Spacer()
                .frame(height: 16)
            Text(titleText)
                .font(Font(FontManager.medium(size: 20)))
            Spacer()
                .frame(height: 10)
            Text(subTitleText)
                .font(Font(FontManager.light(size: 17)))
            Text(actionText)
                .font(Font(FontManager.light(size: 17)))
        }
    }

    static func newNoConnectivityView() -> UIViewController {
        let vc = HostingController(rootView: NoConnectivityView())
        vc.navigationItem.hidesBackButton = true

        return vc
    }
}


