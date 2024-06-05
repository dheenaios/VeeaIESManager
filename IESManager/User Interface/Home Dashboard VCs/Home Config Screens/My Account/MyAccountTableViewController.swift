//
//  MyAccountTableViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking


/// My Account is shared between Enterprise and Home UIs
class MyAccountTableViewController: HomeUserBaseTableViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .my_account_screen

    
    private struct TableStructure {
        
        // Account settings
        static let changePassword = IndexPath(row: 0, section: 0)
        static let logout = IndexPath(row: 1, section: 0)
        
        // Support
        static let supportCenter = IndexPath(row: 0, section: 1)
        static let contactUs = IndexPath(row: 1, section: 1)
        
        // Legal
        static let terms = IndexPath(row: 0, section: 2)
        static let privacyPolicy = IndexPath(row: 1, section: 2)

        // Delete
        static let deleteAccount = IndexPath(row: 0, section: 3)
    }
    
    private let vm = MyAccountTableViewModel()
    
    static func new() -> MyAccountTableViewController {
        let vc = UIStoryboard(name: StoryboardNames.MyAccount.rawValue, bundle: nil).instantiateInitialViewController() as! MyAccountTableViewController
        return vc
    }
    
    //====================================================
    // Header
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var initialsView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    //====================================================
    // Footer
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    //====================================================
    // Cells

    @IBOutlet weak var logoutCell: UITableViewCell!

    //====================================================

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // The Home VC has its title set elsewhere
        if !Target.currentTarget.isHome {
            title = "My Account".localized()
        }
        
        setTheme()
        setAccessibility()
    }

    private func setAccessibility() {
        logoutCell.accessibility(config: AccessibilityConfigurations.logoutRow)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            await UserSessionManager.shared.loadUser()
            await MainActor.run {
                self.setUpHeader()
                self.setUpFooter()
            }
        }
    }
    
    private func setNavBarColor() {
        // This screen has a unique tint for the nav bar
    }
    
    override func setTheme() {
        let cm = InterfaceManager.shared.cm
        
        let navbarColor = cm.background2.colorForAppearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = navbarColor
        appearance.titleTextAttributes = [.foregroundColor: cm.text1.colorForAppearance] // With a red background, make the title more readable.

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance // For iPhone small navigation bar in landscape.
    }
    
    private func setUpHeader() {
        
        // Set up views
        initialsView.makeCircular()
        initialsLabel.font = FontManager.light(size: 27)
        
        nameLabel.font = FontManager.light(size: 27)
        emailLabel.font = FontManager.medium(size: 13)
        
        // Populate
        initialsLabel.text = vm.initials
        nameLabel.text = vm.usersName
        emailLabel.text = vm.usersEmailAddress
    }
    
    private func setUpFooter() {
        appNameLabel.font = FontManager.regular(size: 11)
        versionLabel.font = FontManager.regular(size: 11)
        
        appNameLabel.text = vm.appName
        versionLabel.text = vm.version
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == TableStructure.changePassword {
            handleChangePassword()
        }
        else if indexPath == TableStructure.logout {
            handleLogout()
        }
        else if indexPath == TableStructure.supportCenter {
            handleSupportCenter()
        }
        else if indexPath == TableStructure.contactUs {
            handleContactUs()
        }
        else if indexPath == TableStructure.terms {
            handleTerms()
        }
        else if indexPath == TableStructure.privacyPolicy {
            handlePrivacyPolcy()
        }
        else if indexPath == TableStructure.deleteAccount {
            deleteAccount()
        }
    }
}

// MARK: - Selection Handling
extension MyAccountTableViewController {
    private func handleChangePassword() {
        navigationController?.pushViewController(ChangePasswordViewController(), animated: true)
    }
    
    private func handleLogout() {
        requestLogoutConfirmation()
    }
    
    private func handleSupportCenter() {
        openLink(with: vm.supportCenterUrl)
    }
    
    private func handleContactUs() {
        openLink(with: vm.contactUsUrl)
    }
    
    private func handleTerms() {
        openLink(with: vm.termsUrl)
    }
    
    private func handlePrivacyPolcy() {
        openLink(with: vm.privacyPolicy)
    }

    private func deleteAccount() {
        self.navigationController?.pushViewController(DeleteAccountView.newViewController(),
                                                     animated: true)
    }
    
    private func openLink(with url: String) {
        let miniBrowser = VUIWebViewController(urlString: url)
        self.present(miniBrowser, animated: true, completion: nil)
    }
}

// MARK: - Logout
extension MyAccountTableViewController {
    private func requestLogoutConfirmation() {
        let alertController = UIAlertController(title: "Log out".localized(), message: "Are you sure you want to log out?".localized(), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
        let logoutAction = UIAlertAction(title: "Log out".localized(), style: .destructive, handler: {
            [weak self] _ in
            self?.logout()
        })
        logoutAction.accessibility(config: AccessibilityConfigurations.alertLogoutButton)
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func logout() {
        self.showSpinner(onView: self.view)

        // Check maintainance mode
        Task {
            let checker = MaintainanceModeCheck()
            let isinMaintananceMode = await checker.isInMaintainanceMode(sendMaintainaceModeNotification: true)
            if isinMaintananceMode { return }

            DispatchQueue.main.async {
                self.doLogout()
            }
        }
    }

    private func doLogout() {
        Task {
            let result = await LogoutController.logout()
            await MainActor.run {
                self.removeSpinner()
                switch result {
                case .success, .noFbToken, .couldNotMakeRequestBody:
                    self.navigateToLogin()
                case .noAuthToken:
                    self.logoutFail(message: result.message)
                case .FbTokenError(_):
                    self.logoutFail(message: result.message)
                case .unknown(_):
                    self.logoutFail(message: result.message)
                }
            }
        }
    }

    private func logoutFail(message: String) {
        Logger.log(tag: "MyAccountTableViewController", message: "Logout issue: \(message)")
        navigateToLogin()
    }

    private func navigateToLogin() {
        GroupFavoritesController.shared.clearLocalFavorites()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showLoginFlowCoordinator()
    }
}

extension MyAccountTableViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

class MyAccountTableViewModel {

    let supportCenterUrl = "https://go.veea.com/troubleshooting"
    let contactUsUrl = "https://veea.zendesk.com/hc/en-us/requests/new/"
    let termsUrl = "https://go.veea.com/tos/"
    let privacyPolicy = "https://go.veea.com/privacy/"


    var user = UserSessionManager.shared.currentUser
    
    var initials: String {
        guard let u = user,
              let first = u.firstName.first,
              let last = u.lastName?.first else { return "?" }
        return "\(first)\(last)"
    }
    
    var usersName: String {
        guard let u = user,
              let first = u.firstName,
              let last = u.lastName else { return "?" }
        return "\(first) \(last)"
    }
    
    var usersEmailAddress: String {
        guard let u = user else { return "?"}
        return u.email
    }
    
    var appName: String {
        return Target.targetDisplayName
    }
    
    var version: String {
        if Target.currentTarget.isQA {
            return "Version" + " " + VeeaKit.versions.application + " (\(VeeaKit.versions.build))"
        }

        return "Version" + " " + VeeaKit.versions.application
    }
}
