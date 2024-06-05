//
//  NotificationAuthViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit
import Firebase

class NotificationAuthViewController: UIViewController {
    
    @IBOutlet weak var authStateTextView: UITextView!
    @IBOutlet weak var tokenTextView: UITextView!
    @IBOutlet weak var failureMessageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var firebaseToken: UITextView!
    
    @IBOutlet weak var requestAuthButton: UIButton!
    
    let notificationRequest = PushNotificationRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
    }
    
    private func load() {
        setAuthStateTextView()
        setTokenTextView()
        setDateLabel()
        setFailureMessageTextView()
        setFirebaseTokenTextView()
    }
    
    @IBAction func requestAuth(_ sender: Any) {
        notificationRequest.requestNotificationPermissions {
            self.load()
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        load()
    }
    
    private func setAuthStateTextView() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authStateTextView.text = "\(settings)"
            }
        }
    }
    
    private func setDateLabel() {
        if let date = PushNotificationRequest.apnTokenUpdated {
            let df = DateFormatter()
            df.timeStyle = .short
            dateLabel.text = df.string(from: date)
            return
        }
        
        dateLabel.text = "No date"
    }
    
    private func setTokenTextView() {
        if let t = PushNotificationRequest.apnToken {
            tokenTextView.text = t
            return
        }
        
        tokenTextView.text = "None"
    }
    
    private func setFailureMessageTextView() {
        if let f = PushNotificationRequest.failureMessage {
            failureMessageTextView.text = f
            return
        }
        
        failureMessageTextView.text = "None"
    }
    
    private func setFirebaseTokenTextView() {
        Messaging.messaging().token { t, error in
          if let error = error {
              self.firebaseToken.text = error.localizedDescription
          }
            else if let t = t {
              self.firebaseToken.text = t
          }
        }
    }
}
