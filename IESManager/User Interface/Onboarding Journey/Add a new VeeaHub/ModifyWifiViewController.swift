//
//  ModifyWifiViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 25/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import SwiftUI

class ModifyWifiViewController: OnboardingBaseViewController {
    
    private var finishedClosure: ((HomeHubEnrollmentModel) -> Void)!
    private var details: HomeHubEnrollmentModel!
    
    private var vm = ModifyWifiViewModel()
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var modifySettingsButton: CurvedButton!
    @IBOutlet weak var continueButton: CurvedButton!
    
    @IBOutlet weak var primaryNetworkSsidField: CurvedTextEntryField!
    @IBOutlet weak var primaryNetworkPskField: CurvedTextEntryField!
    @IBOutlet weak var guestNetworkSsidField: CurvedTextEntryField!
    @IBOutlet weak var guestNetworkPskField: CurvedTextEntryField!
    
    static func new(details: HomeHubEnrollmentModel,
                    guestNetworkEnabled: Bool,
                    completion: @escaping ((HomeHubEnrollmentModel) -> Void)) -> ModifyWifiViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserEnrollment.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: "ModifyWifiViewController") as! ModifyWifiViewController
        
        vc.finishedClosure = completion
        vc.details = details
        vc.vm.guestNetworkEnabled = guestNetworkEnabled
        
        return vc
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wi-Fi Settings".localized()
        addCloseButton()
    }

    private func addCloseButton() {

        
        let closeView = CloseButton(inUIView: true) {
            self.dismiss(animated: true, completion: nil)
        }
        let closeUiView = SwiftUIUIView<CloseButton>(view: closeView, requireSelfSizing: true)
        let customButtonWithImage = UIBarButtonItem(customView: closeUiView.make())
        navigationItem.rightBarButtonItem = customButtonWithImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populate()
    }
    
    private func populate() {
        primaryNetworkSsidField.infoLabel.text = "Network Name (SSID)".localized()
        primaryNetworkPskField.infoLabel.text = "Password".localized()
        guestNetworkSsidField.infoLabel.text = "Network Name (SSID)".localized()
        guestNetworkPskField.infoLabel.text = "Password".localized()
        
        primaryNetworkSsidField.textField.text = details.displayWifiSsid
        primaryNetworkPskField.textField.text = details.displayWifiPsk
        guestNetworkSsidField.textField.text = details.displayGuestWifiSsid
        guestNetworkPskField.textField.text = details.displayGUESTWifiPsk
    }
    
    override func setTheme() {
        super.setTheme()
        
        updateNavBarWithCustomColors(color: cm.background2, transparent: true)
        
        // Buttons
        modifySettingsButton.setTitleColor(cm.themeTint.colorForAppearance, for: .normal)
        modifySettingsButton.borderColor = cm.themeTint.colorForAppearance
        modifySettingsButton.fillColor = .white
        modifySettingsButton.titleLabel?.font = FontManager.bigButtonText
        
        infoLabel.font = FontManager.bodyText
    }
    
    @IBAction func revertTapped(_ sender: Any) {
        details.clearWifiSettings()
        populate()
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        details.primarySsid = primaryNetworkSsidField.textField.text!
        details.primaryPsk = primaryNetworkPskField.textField.text!
        details.guestSsid = guestNetworkSsidField.textField.text!
        details.guestPsk = guestNetworkPskField.textField.text!
        
        if let error = vm.ssidPasswordErrors(details: details) {
            showInfoAlert(title: "Error".localized(), message: error)
            return
        }
        
        finishedClosure(details)
        dismiss(animated: true, completion: nil)
    }
}

class ModifyWifiViewModel {
    
    var guestNetworkEnabled = false
    
    /// Returns nil if all is well
    /// - Parameter details: enrollment details
    /// - Returns: Error message. Nil if all is well
    func ssidPasswordErrors(details: HomeHubEnrollmentModel) -> String? {
        let primarySsidResult = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: details.primarySsid)
        let guestSsidResult = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: details.guestSsid)
        let primaryPskResult = SSIDNamePasswordValidation.passwordValidForEnrollment(passString: details.primaryPsk, ssid: details.primarySsid)
        let guestPskResult = SSIDNamePasswordValidation.passwordValidForEnrollment(passString: details.guestPsk, ssid: details.guestPsk)
        
        var errorsString = ""
        
        if let m = primarySsidResult.1 {
            errorsString.append("\(m)\n")
        }
        if let m = primaryPskResult.1 {
            errorsString.append("\(m)\n")
        }
        
        if guestNetworkEnabled {
            if let m = guestSsidResult.1 {
                errorsString.append("\(m)\n")
            }
            if let m = guestPskResult.1 {
                errorsString.append("\(m)\n")
            }
        }
        
        if !errorsString.isEmpty {
            return errorsString
        }
                               
        return nil
    }
}
