//
//  AddDeviceWelcomeViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/8/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class AddDeviceWelcomeViewController: VUIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .advanced_veeahub_settings

    
    var scrollView: UIScrollView!
    var continueButtonContainer: UIVisualEffectView!
    var continueButton: VUIFlatButton?
    
    var flowDelegate: EnrollmentFlowDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonTitle()
        self.parent?.title = "Add VeeaHub".localized()
        

        scrollView = UIScrollView(frame: self.view.bounds)
        scrollVerticalStyle(scrollView)
        self.view.addSubview(scrollView)
        self.scrollView.addOffset(UIConstants.Margin.top)
        
        // Unboxing Image
        let unboxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 140))
        unboxImageView.contentMode = .scaleAspectFit
        unboxImageView.image = UIImage(named: "OnboardingStep1")
        unboxImageView.centerInView(superView: self.view, mode: .horizontal)
        self.scrollView.push(unboxImageView)
        self.scrollView.addOffset(UIConstants.Spacing.standard * 2)
        
        // Title
        let titleLabel = VUITitle(frame: CGRect(x: 0, y: 0, width: UIConstants.contentWidth * 0.85, height: 0),
                                  title: "Add VeeaHub".localized())
        titleLabel.textColor = UIColor.label
        
        titleLabel.centerInView(superView: self.view, mode: .horizontal)
        self.scrollView.push(titleLabel)
        self.scrollView.addOffset(UIConstants.Spacing.small)
        
        // Detail
        let detailsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIConstants.contentWidth * 0.85, height: 0))
        detailsLabel.text = """
        We'll guide you with adding your new VeeaHub to your account. \n\nIf you haven't done so please unpack your VeeaHub as you'll need to scan a QR code underneath it.
        """.localized()
        darkGrayLabelStyle(detailsLabel)
        multilineCenterLabelStyle(detailsLabel)
        detailsLabel.centerInView(superView: self.view, mode: .horizontal)
        self.scrollView.push(detailsLabel)
        
        // Continue button
        self.continueButtonContainer = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        
        if traitCollection.userInterfaceStyle == .dark {
            self.continueButtonContainer = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        }
        
        self.continueButtonContainer.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: 70)
        self.continueButtonContainer.frame.size.height += UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
        
        self.continueButton = VUIFlatButton(frame: CGRect(x: UIConstants.Margin.side, y: UIConstants.Margin.side, width: UIConstants.contentWidth, height: 40),
                                            type: .green,
                                            title: "Add VeeaHub".localized())
        self.continueButton?.accessibility(config: AccessibilityConfigurations.buttonAddVeeaHub)
        self.continueButton!.addTarget(self, action: #selector(AddDeviceWelcomeViewController.continueAction), for: .touchUpInside)
        self.continueButtonContainer.contentView.addSubview(continueButton!)
        
        var statusBarHeight : CGFloat = 0
        statusBarHeight = UIWindow.sceneWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        self.continueButtonContainer.frame.origin.y = self.view.bounds.height - self.continueButtonContainer.frame.height - statusBarHeight
        self.view.insertSubview(continueButtonContainer, aboveSubview: scrollView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkCanProcceed()
        recordScreenAppear()
    }
    
    private func checkCanProcceed() {
        self.continueButton?.isEnabled = UserSessionManager.shared.isUserLoggedIn

        // Make the login call to check
        guard (UserSessionManager.shared.currentUser?.id) != nil else {
            continueButton?.isEnabled = true
            return
        }
        
        continueButton?.isEnabled = true
    }
    
    @objc func continueAction() {
        AnalyticsEventHelper.recordUserEnrollmentStart()
        self.flowDelegate?.next()
    }
    
    func centerScrollViewContent() {
        if scrollView.contentSize.height < self.view.bounds.height {
            let offset = (self.view.bounds.height - continueButtonContainer.frame.height - self.navbarMaxY)/2 - (scrollView.contentSize.height)/2
            self.scrollView.contentInset.top = offset
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        centerScrollViewContent()
    }
    

}
