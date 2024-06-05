//
//  WifiSettingsViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 24/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class OnboardingWiFiSettingsViewController: OnboardingBaseViewController {
    
    // Info
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!

    // Main network
    @IBOutlet weak var ssidView: UIView!
    @IBOutlet weak var ssidInfoLabel: UILabel!
    @IBOutlet weak var ssidNameLabel: UILabel!
    @IBOutlet weak var passwordInfoLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    // Guest Network
    @IBOutlet weak var guestSsidView: UIView!
    @IBOutlet weak var guestnetworkSwitchLabel: UILabel!
    @IBOutlet weak var guestNetworkSwitch: UISwitch!
    @IBOutlet weak var guestSsidInfoLabel: UILabel!
    @IBOutlet weak var guestSsidNameLabel: UILabel!
    @IBOutlet weak var guestPasswordInfoLabel: UILabel!
    @IBOutlet weak var guestPasswordLabel: UILabel!
    
    // Buttons
    @IBOutlet weak var modifySettingsButton: CurvedButton!
    @IBOutlet weak var continueButton: CurvedButton!
    
    static func new() -> OnboardingWiFiSettingsViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserEnrollment.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: "WifiSettingsViewController") as! OnboardingWiFiSettingsViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wi-Fi Settings".localized()

        guestNetworkSwitch.isOn = false
        enableGuestNetwork = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populate()
    }
    
    override func setTheme() {
        super.setTheme()
        
        infoLabel.font = FontManager.bodyText
        learnMoreButton.setTitleColor(cm.themeTint.colorForAppearance, for: .normal)
        learnMoreButton.titleLabel?.font = FontManager.bigButtonText

        // SSID View
        ssidView.backgroundColor = cm.themeTintLightBackground.colorForAppearance
        ssidInfoLabel.font = FontManager.infoTextBold
        ssidNameLabel.font = FontManager.ssidPasswordText
        passwordInfoLabel.font = FontManager.infoTextBold
        passwordLabel.font = FontManager.ssidPasswordText
        
        // Guest SSID View
        guestSsidView.backgroundColor = cm.themeTintLightBackground.colorForAppearance
        guestSsidInfoLabel.font = FontManager.infoTextBold
        guestSsidNameLabel.font = FontManager.ssidPasswordText
        guestPasswordInfoLabel.font = FontManager.infoTextBold
        guestPasswordLabel.font = FontManager.ssidPasswordText

        // Buttons
        modifySettingsButton.setTitleColor(cm.themeTint.colorForAppearance, for: .normal)
        modifySettingsButton.borderColor = cm.themeTint.colorForAppearance
        modifySettingsButton.fillColor = .white
        modifySettingsButton.titleLabel?.font = FontManager.bigButtonText
        
        infoLabel.font = FontManager.bodyText
    }
    
    @IBAction func helpTapped(_ sender: Any) {
        
    }
    
    @IBAction func guestSsidSwitchChanged(_ sender: Any) {
        enableGuestNetwork = guestNetworkSwitch.isOn
    }
    
    @IBAction func modifySettingsTapped(_ sender: Any) {
        let nc = navigationController as! HomeUserSessionNavigationController
        let details = nc.newEnrollment

        let vc = ModifyWifiViewController.new(details: details!,
                                              guestNetworkEnabled: guestNetworkSwitch.isOn) { modifiedDetails in
            nc.newEnrollment = modifiedDetails
            self.populate()
        }
                
        let newNc = UINavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .pageSheet
        
        present(newNc, animated: true, completion: nil)
    }

    @IBAction func continueTapped(_ sender: Any) {
        let nc = navigationController as! HomeUserSessionNavigationController
        
        nc.newEnrollment.primarySsid = ssidNameLabel.text!
        nc.newEnrollment.primaryPsk = passwordLabel.text!
        nc.newEnrollment.guestNetworkIsOn = guestNetworkSwitch.isOn

        nc.newEnrollment.guestSsid = guestSsidNameLabel.text!
        nc.newEnrollment.guestPsk = guestPasswordLabel.text!
        
        sendAndShowComplete()
    }
    
    private func populate() {
        let nc = navigationController as! HomeUserSessionNavigationController
        
        ssidNameLabel.text = nc.newEnrollment.displayWifiSsid
        passwordLabel.text = nc.newEnrollment.displayWifiPsk
        guestSsidNameLabel.text = nc.newEnrollment.displayGuestWifiSsid
        guestPasswordLabel.text = nc.newEnrollment.displayGUESTWifiPsk
    }
    
    private var enableGuestNetwork: Bool = false {
        didSet {
            if enableGuestNetwork { guestSsidView.alpha = 1.0 }
            else { guestSsidView.alpha = 0.3 }
            
            guestNetworkSwitch.alpha = 1.0
        }
    }
}
