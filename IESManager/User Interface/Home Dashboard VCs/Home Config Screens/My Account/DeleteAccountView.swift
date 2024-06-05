//
//  DeleteAccountView.swift
//  IESManager
//
//  Created by Richard Stockdale on 16/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SwiftUI

struct DeleteAccountView: View {
    private let deteteDescription = "Are you sure you want to delete your account?".localized()
    private let moreInfo = "You'll have 30 days to re-login with your credentials. If you wish to cancel the account deletion in that period, please contact customer support.  After this period, your account will be irreversibly deleted.".localized()
    private let buttonTitle = "Delete my account".localized()

    private let deteteDescriptionFont = FontManager.bigButtonText
    private let moreInfoFont = FontManager.bodyText


    private var workingAlert = UIAlertController(title: "Working...".localized(),
                                                 message: "Please wait a moment".localized(),
                                                 preferredStyle: .alert)

    @EnvironmentObject var host: HostWrapper

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(deteteDescription)
                .font(Font(deteteDescriptionFont))
            Text(moreInfo)
                .font(Font(moreInfoFont))

            Spacer()

            ActionButton(title: buttonTitle,
                         bgColor: InterfaceManager.shared.cm.statusRed) {
                showWarning()
            }
        }
        .padding()
        .onAppear {
            hideTabBar(hideTabBar: true)
        }
    }

    private func hideTabBar(hideTabBar: Bool) {
        host.controller?.tabBarController?.tabBar.isHidden = hideTabBar
    }

    private func showWarning() {
        let alert = UIAlertController(title: "Delete Account".localized(),
                                      message: "Are you sure you want to delete your account?".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { action in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                host.controller?.present(self.workingAlert, animated: true)
                Task { await self.makeDeleteCall() }
            }
        }))

        host.controller?.present(alert, animated: true)
    }

    private func makeDeleteCall() async {
        let deleteController = DeleteAccountController()
        let success = await deleteController.deleteAccount()
        self.handleDeleteResponse(success: success)

    }

    func handleDeleteResponse(success: Bool) {
        self.workingAlert.dismiss(animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !success {
                let alert = UIAlertController(title: "Something went wrong".localized(),
                                              message: "We were unable to delete your account.\nPlease try again later".localized(),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
                host.controller?.present(alert, animated: true)

                return
            }

            host.controller?.showInfoMessage(message: "Delete Account Request Sent".localized())
            host.controller?.navigationController?.popViewController(animated: true)
        }
    }

    private func logoutFail(message: String) {
        let alert = UIAlertController.init(title: "Failed!".localized(),
                                           message: message,
                                           preferredStyle: .alert)

        alert.addAction(UIAlertAction.init(title: "Ok".localized(), style: .cancel, handler: nil))

        host.controller?.present(alert, animated: true)
    }

    private func logoutSuccess() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showLoginFlowCoordinator()
    }

    static func newViewController() -> UIViewController {
        let vc = HostingController(rootView: DeleteAccountView())
        vc.title = "Delete Account".localized()

        return vc
    }
}
