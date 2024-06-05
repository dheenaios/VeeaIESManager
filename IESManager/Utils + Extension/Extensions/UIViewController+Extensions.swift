//
//  UIViewController+Extensions.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/22/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

/// General helpers
extension UIViewController {
    
    func backButtonHidden(_ hidden: Bool) {
        if let parent = parent {
            if !parent.isKind(of: UINavigationController.self) {
                parent.navigationItem.setHidesBackButton(hidden, animated: true)
                return
            }
        }
        
        self.navigationItem.setHidesBackButton(hidden, animated: true)
    }
    
    func fixTitleItemBarColor(largeTitleFontSize: CGFloat? = nil) {
        // Fix for title bar color bug in iOS 13.4
        let cm = InterfaceManager.shared.cm

        let navbarColor = cm.background1
        setTitleItemBar(color: navbarColor,
                        transparent: true,
                        largeTitleFontSize: largeTitleFontSize)
    }
     
    func setTitleItemBar(color: DynamicColor,
                         transparent: Bool,
                         largeTitleFontSize: CGFloat? = nil) {
        let navbarColor = color.colorForAppearance
        
        guard let nb = navigationController?.navigationBar else {
            return
        }
        
        setNavigationBarAttributes(navigationBar: nb,
                                   color: navbarColor,
                                   transparent: transparent,
                                   largeTitlesFontSize: largeTitleFontSize)
    }
    
    func setNavigationBarAttributes(navigationBar: UINavigationBar,
                                    color: UIColor,
                                    transparent: Bool,
                                    largeTitlesFontSize: CGFloat? = nil) {
        let cm = InterfaceManager.shared.cm
        
        let appearance = UINavigationBarAppearance()

        if transparent {
            appearance.configureWithTransparentBackground()
        }

        appearance.backgroundColor = color
        appearance.titleTextAttributes = [.foregroundColor: cm.text1.colorForAppearance] // With a red background, make the title more readable.

        if let largeTitlesFontSize {
            appearance.largeTitleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: largeTitlesFontSize)]
        }

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance // For iPhone small navigation bar in landscape.
    }
    
    func updateNavBarWithDefaultColors(largeTitleFontSize: CGFloat? = nil) {
        fixTitleItemBarColor(largeTitleFontSize: largeTitleFontSize)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setUIDefaults()
    }
    
    func updateNavBarWithCustomColors(color: DynamicColor, transparent: Bool) {
        setTitleItemBar(color: color, transparent: transparent)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setUIDefaults()
    }
    
    /** Max Y of UINavigationBar frame */
    var navbarMaxY: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.height ?? 0
    }
    
    /** Pop to the root of navigation viewController with animation */
    @objc func popToRootAnimated() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Large titles
    func enableLargeTitles(enable: Bool = true) {
        self.navigationController?.navigationBar.prefersLargeTitles = enable
    }
    
    func setLargeTitleMode(mode: UINavigationItem.LargeTitleDisplayMode) {
        self.navigationController?.navigationItem.largeTitleDisplayMode = mode
    }
    
    var viewSafeAreaInsets: UIEdgeInsets {
        get {
            return self.view.safeAreaInsets
        }
    }
    
    // MARK: - Add/Remove Child VC
    
    /** Adds child ViewController to current ViewController and calls didMove*/
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /** Removes ViewController from its parent */
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    /** Removes back button title from Navigation bar*/
    func removeBackButtonTitle() {
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }
    
    func logScreenName() {
        Logger.log(tag: "Nav Event", message: "User opened \(viewControllerName)")
    }

    var viewControllerName: String {
        String(describing: self)
    }
}

// MARK: - Search
extension UIViewController {
    
    
    /// Adds a search bar to the navigational controller
    /// - Parameters:
    ///   - placeHolderText: The placeholder text to be displayed when no text is entered
    ///   - searchResultsUpdater: The object delegated to deal with the query
    ///   - hostNavigationItem: The navigational item which will display the search bar. Pass in nil if the current view controllers own navItem bar is to be used.
    @discardableResult func addSearchBar(placeHolderText: String,
                                         searchResultsUpdater: UISearchResultsUpdating,
                                         hostNavigationItem: UINavigationItem?) -> UISearchBar {
        let controller = addSearchAndCreateController(placeHolderText: placeHolderText,
                                                      searchResultsUpdater: searchResultsUpdater,
                                                      hostNavigationItem: hostNavigationItem)
        
        return controller.searchBar
    }
    
    @discardableResult func addSearchAndCreateController(placeHolderText: String,
                                                         searchResultsUpdater: UISearchResultsUpdating,
                                                         hostNavigationItem: UINavigationItem?) -> UISearchController {
        var na = self.navigationItem
        if let hostNavigationItem = hostNavigationItem {
            na = hostNavigationItem
        }
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = searchResultsUpdater
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = placeHolderText
        na.searchController = searchController
        na.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        searchController.searchBar.tintColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
        searchController.searchBar.searchTextField.textColor = InterfaceManager.shared.cm.text1.colorForAppearance
        searchController.searchBar.searchTextField.leftView?.tintColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
        
        return searchController
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIWindow.sceneWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
