//
//  ConfirmEnrollmentSettingsViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 2/5/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

protocol ConfirmEnrollmentSettingsDelegate {
    func confirmSettings()
}


class ConfirmEnrollmentSettingsViewController: TabTableViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .enterprise_onboarding_screen

    var doneButton: VUIAnimatedButton!
    
    var datasource = ConfirmEnrollmentSettingsDataSource()
    var enrollmentSettings: Enrollment!
    var delegate: ConfirmEnrollmentSettingsDelegate?

    convenience init(settings: Enrollment, delegate: ConfirmEnrollmentSettingsDelegate) {
        self.init()
        self.enrollmentSettings = settings
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Confirm".localized()
        self.removeBackButtonTitle()
        
        // Header View with IES details
        let headerView = HeaderImageViewWithTitle(image: nil, title: "Confirm Settings".localized(),
                                                  detailText: "Please review and confirm the following settings".localized())
        tableView.tableHeaderView = headerView
        datasource.enrollmentData = enrollmentSettings
        tableView.dataSource = datasource
        
        // Done button
        var doneButtonContainer = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        
        if traitCollection.userInterfaceStyle == .dark {
            doneButtonContainer = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        }
        
        doneButtonContainer.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: 70)
        doneButtonContainer.frame.size.height += UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
        doneButton = VUIAnimatedButton(frame: CGRect(x: UIConstants.Margin.side, y: UIConstants.Margin.side, width: UIConstants.contentWidth, height: 40), title: "Confirm".localized(), color: .vGreen)
        
        doneButton.accessibility(config: AccessibilityConfigurations.buttonConfirmSettings)
        
        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        doneButtonContainer.contentView.addSubview(doneButton)
        doneButtonContainer.frame.origin.y = self.view.bounds.height - doneButtonContainer.frame.height - self.navbarMaxY
        doneButtonContainer.frame.origin.y = self.view.bounds.height - doneButtonContainer.frame.height
        self.view.insertSubview(doneButtonContainer, aboveSubview: tableView)
        
        // Navigation item
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ConfirmEnrollmentSettingsViewController.cancelEnrollment))
        self.navigationItem.rightBarButtonItem = cancelButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    @objc func doneAction() {
        let impact = UINotificationFeedbackGenerator()
        AnalyticsEventHelper.recordDeviceEnrollmentStart(deviceId: self.enrollmentSettings.code)
        EnrollmentService.startEnrollment(data: self.enrollmentSettings, success: {
           
            self.doneButton.status = (UIImage(named:"checkmark")!, UIColor.vGreen)
            impact.notificationOccurred(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                self.enrollmentComplete()
                AnalyticsEventHelper.recordDeviceEnrollmentSuccess(deviceId: self.enrollmentSettings.code)
            })
            
        }) { (err) in
            impact.notificationOccurred(.error)
            self.doneButton.finish()
            showAlert(with: "Failed to add VeeaHub".localized(), message: err)
            AnalyticsEventHelper.recordDeviceEnrollmentFailed(deviceId: self.enrollmentSettings.code, reason: err)
        } errData: { (errorMeta) in
            self.showErrorHandlingAlert(title: errorMeta.title ?? "", message: errorMeta.message ?? "", suggestions: errorMeta.suggestions ?? [])
        }
        
    }
    
    func enrollmentComplete() {
        self.delegate?.confirmSettings()
    }
    
    @objc func cancelEnrollment() {
        AnalyticsEventHelper.recordUserEnrollmentCancelled(screenName: "Confirm Screen")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
