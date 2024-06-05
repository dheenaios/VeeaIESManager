//
//  ConnectDeviceViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/5/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class ConnectDeviceViewController: UIViewController, AnalyticsScreenViewEventProtocol {

    var screenName: AnalyticsEvents.ScreenNames = .enterprise_onboarding_screen
    let titleText = "Connect VeeaHub".localized()

    var flowDelegate: EnrollmentFlowDelegate?
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.systemBackground
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = titleText
        self.setUp()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    func setUp() {
        
        scrollView = UIScrollView(frame: self.view.bounds.insetBy(dx: 0, dy: -130))
        scrollVerticalStyle(scrollView)
        self.view.addSubview(scrollView)
        
        let deviceImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 114, height: 450))
        deviceImageView.image = UIImage(named: "OnboardingStep6")
        deviceImageView.centerInView(superView: self.view, mode: .horizontal)
        deviceImageView.contentMode = .scaleAspectFit
        self.scrollView.push(deviceImageView)
        self.scrollView.addOffset(UIConstants.Spacing.standard)
        
        // Title
        let titleLabel = VUITitle(frame: CGRect(x: 0, y: 0, width: UIConstants.contentWidth * 0.85, height: 0), title: "Connect your VeeaHub".localized())
        titleLabel.textColor = UIColor.label
        
        titleLabel.centerInView(superView: self.view, mode: .horizontal)
        self.scrollView.push(titleLabel)
        self.scrollView.addOffset(UIConstants.Spacing.standard * 2)
        
        // Detail
        let detailsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIConstants.contentWidth * 0.85, height: 0))
        detailsLabel.text = """
        Your new VeeaHub is now activating. \n\nPlease connect your VeeaHub to power and Internet (using an Ethernet cable). \n\nYou can check the status of your VeeaHub under your mesh listing.
        """.localized()
        darkGrayLabelStyle(detailsLabel)
        multilineCenterLabelStyle(detailsLabel)
        detailsLabel.centerInView(superView: self.view, mode: .horizontal)
        self.scrollView.push(detailsLabel)
        
        // Continue button
        var continueButtonContainer = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        if traitCollection.userInterfaceStyle == .dark {
            continueButtonContainer = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        }
        
        continueButtonContainer.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: 70)
        continueButtonContainer.frame.size.height += UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
        
        let continueButton = VUIFlatButton(frame: CGRect(x: UIConstants.Margin.side, y: UIConstants.Margin.side, width: UIConstants.contentWidth, height: 40), type: .green, title: "Done".localized())
        continueButton.accessibility(config: AccessibilityConfigurations.buttonConnectDeviceDone)

        continueButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        continueButtonContainer.contentView.addSubview(continueButton)
        continueButtonContainer.frame.origin.y = self.view.bounds.height - continueButtonContainer.frame.height - self.navbarMaxY
        continueButtonContainer.frame.origin.y = self.view.bounds.height - continueButtonContainer.frame.height
        self.view.insertSubview(continueButtonContainer, aboveSubview: scrollView)
    }
    
    @objc func doneAction() {
        self.flowDelegate?.completeEnrollment()
        NotificationCenter.default.post(name: Notification.Name.updateMeshes, object: nil)
    }
}
