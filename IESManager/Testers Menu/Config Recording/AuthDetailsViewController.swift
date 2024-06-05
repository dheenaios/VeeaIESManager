//
//  AuthDetailsViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 14/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class AuthDetailsViewController: UIViewController {

    @IBOutlet weak var expiresLabel: UILabel!
    @IBOutlet weak var tokenField: UITextView!
    @IBOutlet weak var userIdField: UILabel!
    
    private let noTokenText = "No token"
    private let noExpiryText = "Expires: No token"
    
    @IBAction func copyButton(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = tokenField.text
    }
    
    private func setExpiryDate() {
        guard let d = AuthorisationManager.shared.expiryDate else {
            expiresLabel.text = noExpiryText
            return
        }
        
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .long
        
        var dateString = df.string(from: d)
        
        if AuthorisationManager.shared.tokenExpired {
            dateString.append(" (Expired)")
        }
        
        expiresLabel.text = "Expires: ".localized() +  dateString
    }
    
    private func setUserId() {
        let userId = AuthorisationManager.shared.userIdLegacy
        
        if userId == -1 {
            userIdField.text = "User Id: ?".localized()
            return
        }
        
        userIdField.text = "User Id: ".localized() + "\(userId)"
    }
    
    private func setToken() {
        guard let t = AuthorisationManager.shared.formattedAuthToken else {
            tokenField.text = noTokenText
            return
        }
        
        tokenField.text = t//"Bearer \(t)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setExpiryDate()
        setToken()
        setUserId()
    }
}
