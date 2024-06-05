//
//  AppDelegate.swift
//  VeeaHub Manager
//
//  Created by Al on 21/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import Firebase
import AppAuth
import IQKeyboardManagerSwift
import UserNotifications
import SharedBackendNetworking
import WidgetKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AuthFlowSessionManagerProtocol {
    
    var window: UIWindow?
    var timer: Timer?
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    let realmManager = VeeaRealmsManager()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        firebaseConfigure()
        
        setUIDefaults()
        IQKeyboardManager.shared.enable = true
        
        // Load inital view here
        showLoginFlowCoordinator()
        
        IPConnectionViewController.updateOverrideState()
        UpdateManager.shared.syncRemoteConfiguration()
        
        UNUserNotificationCenter.current().delegate = self
        handleNotifLaunch(launchOptions: launchOptions)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showMaintModeScreen(_:)),
                                               name: SharedBackendNetworking.Notification.Name.BackendDidGoIntoMaintainanceMode,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showOfflineWarning),
                                               name: Notification.Name.NetworkStateDidChange,
                                               object: nil)
        return true
    }

    private func firebaseConfigure() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
    }
        
    func showLoginFlowCoordinator() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LoginFlowCoordinator()
        window?.makeKeyAndVisible()
    }

    @objc func showMaintModeScreen(_ notification: Notification) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let errorMode = notification.object as? ErrorMetaDataModel {
            let vc = HostingController(rootView: MaintenanceModeView(errorModel: errorMode))
            window?.rootViewController = vc
        }
        else {
            let vc = HostingController(rootView: MaintenanceModeView(errorModel: nil))
            window?.rootViewController = vc
        }

        window?.makeKeyAndVisible()
    }

    @objc func showOfflineWarning() {
        if InternetConnectionMonitor.shared.connectivityStatus == .Disconnected {
            if let topController = AppDelegate.getTopController() {
                topController.showInfoWarning(message: "Your device is not connected to a network or the internet".localized())
            }
        }
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                if url.absoluteString.contains("auth/realms/veea/login-actions/") {
                    // Dismiss the safari view controller
                    guard let topVc = (UIApplication.topViewController()) else {
                        return false
                    }
                    
                    // Getting Use of undeclared type 'SFAuthenticationViewController' error if checking type directly.
                    // so check from the class name
                    
                    let className = String(describing: topVc.self)
                    //print(className)
                    
                    if className.contains("UIAlertController") || className.contains("SFAuthenticationViewController") {
                        topVc.dismiss(animated: true) {
                            self.showEmailVerification(webPageUrl: url)
                        }
                        
                        return false
                    }
                    else if className.contains("LoginViewController") {
                        self.showEmailVerification(webPageUrl: url)
                    }
                }
            }
        }
        
        return true
    }
    
    func showEmailVerification(webPageUrl: URL) {
        guard let topVc = (UIApplication.topViewController() as? LoginViewController) else {
            return
        }
        
        let verificationVc = EmailVerificationViewController()
        verificationVc.load(pageUrl: webPageUrl, delegate: self)
        topVc.present(verificationVc, animated: true, completion: nil)
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Sends the URL to the current authorization flow (if any) which will
        // process it if it relates to an authorization response.
        if let authorizationFlow = self.currentAuthorizationFlow,
           authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.currentAuthorizationFlow = nil
            
            return true
        }
        
        // Your additional URL handling (if any)
        
        return false
    }
    
    func setUIDefaults() {
        let cm = InterfaceManager.shared.cm
        
        window?.tintColor = cm.themeTint.colorForAppearance
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = cm.themeTint.colorForAppearance
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = cm.background1.colorForAppearance
        appearance.titleTextAttributes = [.foregroundColor: cm.text1.colorForAppearance]
        appearance.largeTitleTextAttributes = [.foregroundColor: cm.text1.colorForAppearance]

        let barAppearance = UINavigationBar.appearance()
        barAppearance.barTintColor = cm.background1.colorForAppearance
        barAppearance.tintColor = cm.themeTint.colorForAppearance
        barAppearance.standardAppearance = appearance
        barAppearance.compactAppearance = appearance
        barAppearance.scrollEdgeAppearance = appearance
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if UserSettings.disconnectFromHubWhenDone == true {
            shutDownNetwork()
        }

        PushNotificationRequest.sendTokenToBackendIfNeeded()
        reloadWidgets()
    }

    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        InternetConnectionMonitor.shared.startMonitoring()
        reloadWidgets()
        UpdateRequired.reset()

        if NetworkCallLogger.recordCalls {
            UIApplication.topViewController()?.showInfoWarning(message: "Recording network calls\nSee tester menu")
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        PushNotificationRequest.sendTokenToBackendIfNeeded()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if UserSettings.disconnectFromHubWhenDone == true {
            shutDownNetwork()
        }
    }

    private func shutDownNetwork() {
        HubApWifiConnectionManager.shared.currentlyConnectedHub = nil
        WiFi.disconnectFromAllNetworks()
        InternetConnectionMonitor.shared.stopMonitoring()
    }
}

// MARK: - Notifications from closed state
extension AppDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken
                     deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        PushNotificationRequest.apnToken = token
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
                     error: Error) {
        //print("Failed to register: \(error)")
        PushNotificationRequest.failureMessage = error.localizedDescription
    }
    
    private func handleNotifLaunch(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        let notificationOption = launchOptions?[.remoteNotification]
        guard let notification = notificationOption as? [String: AnyObject],
              let aps = notification["aps"] as? [String: AnyObject] else {
                  return
              }
        
        RemoteNotificationHandler.handleNotification(application: nil,
                                                     dict: aps,
                                                     completionHandler: nil)
    }
    
    private func handleNotifWhenAlreadyLaunched(application: UIApplication,
                                                userInfo: [AnyHashable : Any],
                                                fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard (userInfo["aps"] as? [String: AnyObject]) != nil else {
            completionHandler(.failed)
            return
        }
        
        RemoteNotificationHandler.handleNotification(application: application,
                                                     dict: userInfo,
                                                     completionHandler: completionHandler)
    }
    
    static func getTopController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        
        return nil
    }
}

extension AppDelegate: EmailVerificationViewControllerDelegate {
    func doneAndVerfied() {
        let ac = UIAlertController.init(title: "Email Verified".localized(), message: "You can now log in".localized(), preferredStyle: .alert)
        ac.addAction(UIAlertAction.init(title: "Ok".localized(), style: .cancel, handler: nil))
        UIApplication.topViewController()?.present(ac, animated: true, completion: nil)
    }
    
    func pageDismissed() {
        // Not used yet
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        RemoteNotificationHandler.handleUnUserNotificationCentreNotification(userInfo: userInfo)
        completionHandler()
    }
}
