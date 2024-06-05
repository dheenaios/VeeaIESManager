//
//  UIAlert+Extension.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/31/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    fileprivate struct AlertWindow {
        static var current: UIWindow?
        static var previous: UIWindow?
    }
    
    func show() {
        // Store current window for later
        AlertWindow.previous = UIWindow.sceneWindow
        AlertWindow.previous?.isUserInteractionEnabled = true
        close()
        // Create new window for showing alert
        AlertWindow.current = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        AlertWindow.current?.rootViewController = vc
        AlertWindow.current?.windowLevel = UIWindow.Level.alert + 1
        AlertWindow.current?.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
    
    func close() {
        AlertWindow.current?.resignKey()
        
        AlertWindow.previous?.makeKeyAndVisible()
        AlertWindow.previous?.isUserInteractionEnabled = true
        AlertWindow.current = nil
        AlertWindow.previous = nil
        self.dismiss(animated: true, completion: nil)
    }
}


class CustomAlertAction : NSObject {
    var title : String!
    var style : UIAlertAction.Style!
    var callBack : Callback?
    
    public convenience init(title: String?, style: UIAlertAction.Style, callBack: Callback? = nil) {
        self.init()
        self.title = title
        self.style = style
        self.callBack = callBack
    }
}


func showAlert(with title: String, message: String, callback: Callback? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close".localized(), style: .default, handler: { (_) in
        if let callback = callback {
            callback()
        }
        
        alert.close()
    }))
    alert.show()
}


/// Show an alert with an OK and Cancel optiko
/// - Parameters:
///   - title: The title
///   - message: The message
///   - callback: Called if ok is clicked
func showAlertWithOkCancel(with title: String, message: String, callback: Callback? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (_) in
        alert.close()
    }))
    alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { (_) in
        if let callback = callback {
            callback()
        }

        alert.close()
    }))
    alert.show()
}

func showAlert(with title: String, message: String, actions : [CustomAlertAction]?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if actions != nil || !actions!.isEmpty {
        actions!.forEach { (action) in
            let alertAction = UIAlertAction(title: action.title, style: action.style) { (act) in
                alert.close()
                action.callBack?()
            }
            alert.addAction(alertAction)
        }
    }else{
        alert.addAction(UIAlertAction(title: "Close".localized(), style: .default, handler: { (_) in
            alert.close()
        }))
    }
    alert.show()
}
