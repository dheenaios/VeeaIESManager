//
//  UIViewController+Help.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 26/05/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

extension UIViewController {
    
    
    /// Add a help icon to the right bar button item space.
    /// - Parameter tapped: A call back for when help is tapped
    func addHelpIcon(tapped: @escaping () -> Void) {
        
        guard var items = navigationItem.rightBarButtonItems else { return }
        
        // Check if the help button is there. If it is, assign the call back
        for item in items {
            if item.tag == helpButtonTag {
                item.actionClosure = tapped
                return
            }
        }
        
        let helpButton = UIBarButtonItem()
        helpButton.tag = helpButtonTag
        helpButton.image = UIImage(systemName: "questionmark.circle")
        helpButton.actionClosure = tapped
        items.append(helpButton)
        
        navigationItem.rightBarButtonItems = items
    }
    
    func displayHelpFile(file: InAppHelpFile, push: Bool) {
        /// Get the string load that
        guard let content = file.getMdText() else {
            return
        }
        
        let storyBoard = UIStoryboard(name: "InlineHelp", bundle: nil)
        
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "InlineHelpViewController") as? InlineHelpViewController else {
            return
        }
        
        vc.loadText(textString: content)
        if push {
            vc.removeDone()
            navigationController?.pushViewController(vc, animated: true)
            
            return
        }
        
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
        
    }
    
    private var helpButtonTag: Int {
        956 // A random tag to identify the button
    }
}

extension UIBarButtonItem {
    private struct AssociatedObject {
        static var key = "action_closure_key"
    }

    var actionClosure: (()->Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObject.key) as? ()->Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObject.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            target = self
            action = #selector(didTapButton(sender:))
        }
    }

    @objc func didTapButton(sender: Any) {
        actionClosure?()
    }
}
