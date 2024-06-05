//
//  LogsViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 28/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit


class LogsViewController: HelpViewController {
    
    var lastText: String?

    private var updateTimer: Timer?
    @IBOutlet weak var toolBar: UIToolbar!

    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchBarTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLogText()
        
        // Bring the tool bar to the top as the downview will cover it
        view.bringSubviewToFront(toolBar)

        searchBar.isHidden = true
    }


    @IBAction func toggleSearchBar(_ sender: Any) {
        searchBar.isHidden = !searchBar.isHidden
        self.view.bringSubviewToFront(searchBar)
        searchBarTextField.resignFirstResponder()
    }


    @IBAction func tagSearchChanged(_ sender: Any) {
        //print("Changed")

    }

    @IBAction func shareButtonTapped(_ sender: Any) {
        let shareText = LoggingHelper.getLogReport()
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func clearLogsTapped(_ sender: Any) {
        LoggingHelper.clearLogs()
        lastText = nil
        updateLogText()
    }
    

    private func startTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        updateTimer?.invalidate()
    }
    
    @objc private func fireTimer() {
        updateLogText()
    }
    
    private func updateLogText() {
        
        // Update the screen if there has been an update
        let newText = Logger.shared.getSessionLogsWithTag(searchBarTextField.text ?? "",
                                                          reversed: false)
        
        if newText != lastText {
            loadText(textString: newText)
            
            lastText = newText
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
    }
}
