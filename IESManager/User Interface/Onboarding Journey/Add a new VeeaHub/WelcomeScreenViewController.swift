//
//  WelcomeScreenViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 18/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class WelcomeScreenViewController: OnboardingBaseViewController {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var continueButton: CurvedButton!
    @IBOutlet weak var radioMastImageView: UIImageView!
    
    static func new() -> WelcomeScreenViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserEnrollment.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: "WelcomeScreenViewController") as! WelcomeScreenViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome!"
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideBack = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func logout(_ sender: Any) {
        navController.logout()
    }
    
    override func setTheme() {
        super.setTheme()
        logoutButton.tintColor = cm.themeTint.colorForAppearance
        
        welcomeText.textColor = cm.text1.colorForAppearance
        welcomeText.font = FontManager.bodyText
        
        infoText.textColor = cm.textWarningRed1.colorForAppearance
        infoText.font = FontManager.infoText
        
        continueButton.backgroundColor = cm.themeTint.colorForAppearance
        continueButton.setTitleColor(cm.textWhite.colorForAppearance, for: .normal)
        radioMastImageView.tintColor = cm.textWarningRed1.colorForAppearance
    }
}
