//
//  EnrollmentCompleteViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 25/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class EnrollmentCompleteViewController: OnboardingBaseViewController {

    // Buttons
    @IBOutlet weak var addAnother: CurvedButton!
    @IBOutlet weak var continueButton: CurvedButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    
    static func new() -> EnrollmentCompleteViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserEnrollment.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: "EnrollmentCompleteViewController") as! EnrollmentCompleteViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        title = "Complete".localized()
    }
    
    override func setTheme() {
        super.setTheme()
                
        // Buttons
        addAnother.setTitleColor(cm.themeTint.colorForAppearance, for: .normal)
        addAnother.borderColor = cm.themeTint.colorForAppearance
        addAnother.fillColor = .white
        addAnother.titleLabel?.font = FontManager.bigButtonText
        
        // Labels
        infoLabel.font = FontManager.bodyText
        infoLabel.textColor = cm.text1.colorForAppearance
        warningLabel.textColor = cm.textWarningRed1.colorForAppearance
        warningLabel.font = FontManager.bodyText
    }
    
    
    @IBAction func addAnotherTapped(_ sender: Any) {
        navController.startFollowUpEnrollment()
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        let dashboard = LoadingUserDetailsViewController.new()
        navController.pushViewController(dashboard, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
