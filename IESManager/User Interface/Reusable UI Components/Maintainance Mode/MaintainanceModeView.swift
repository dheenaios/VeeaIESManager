//
//  MaintainanceModeView.swift
//  IESManager
//
//  Created by Richard Stockdale on 31/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import SwiftUI
import SharedBackendNetworking

// https://veea.atlassian.net/browse/VHM-1500

struct MaintenanceModeView: View {

    @EnvironmentObject var host: HostWrapper

    private let contactUsUrl = "https://go.veea.com/support/contact/"
    private var titleText = "We'll be right back."
    private var messageText = "We are performing maintenance on this service. We expect this to take no longer than 30 minutes."
    private let textBlock2: LocalizedStringKey = "If you have any questions, please **contact support** for help."
    private let textBlock3 = "Thank you for your patience."
    private let contactSupportButtonText = "Contact Support"
    private let retryButtonText = "Retry"

    public init(errorModel: ErrorMetaDataModel?) {
        if let errorModel = errorModel {
            self.titleText = errorModel.response.title
            self.messageText = errorModel.response.message
        }
    }

    @ObservedObject private var vm = MaintenanceModeViewModel()

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()

            Image("MaintenanceMode")
            Text(titleText)
                .font(Font(FontManager.bold(size: 24)))
                .multilineTextAlignment(.center)

            Text(messageText)
                .font(Font(FontManager.bodyText))
                .multilineTextAlignment(.center)

            Text(textBlock2)
                .font(Font(FontManager.bodyText))
                .multilineTextAlignment(.center)


            Text(textBlock3)
                .font(Font(FontManager.bodyText))
                .multilineTextAlignment(.center)

            Spacer()

            ClearBorderedActionButton(title: contactSupportButtonText) {
                openSupportLink()
            }
            ActionButton(title: retryButtonText,
                         bgColor: InterfaceManager.shared.cm.themeTint) {
                retryConnection()
            }
                         .disabled(vm.checking)
                         .opacity(vm.retryButtonOpacity)
        }
        .padding()
        .onDisappear{
            vm.stopTimer()
        }
    }

    private func retryConnection() {
        if !vm.checking {
            vm.check()
        }
    }

    private func openSupportLink() {
        let miniBrowser = VUIWebViewController(urlString: contactUsUrl)
        self.host.controller?.present(miniBrowser, animated: true, completion: nil)
    }
}
