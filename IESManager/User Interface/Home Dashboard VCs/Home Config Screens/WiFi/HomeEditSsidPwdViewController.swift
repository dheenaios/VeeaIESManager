//
//  HomeEditSsidPwdViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 19/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class HomeEditSsidPwdViewController: HomeUserBaseViewController {

    enum HomeEditSsidPwdViewControllerMode {
        case ssid
        case pwd
        case guestSsid
        case guestPwd

        var isPrimary: Bool {
            if self == .ssid || self == .pwd {
                return true
            }

            return false
        }
    }
    
    private var vm: HomeEditSsidPwdViewModel?
    
    var completion: ((String, HomeEditSsidPwdViewControllerMode) -> Void)!
    
    @IBOutlet weak var textEntryField: CurvedTextEntryField!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var dividerView: UIView!
    
    @IBOutlet weak var broadcastView: UIView!
    @IBOutlet weak var broadcastLabel: UILabel!
    @IBOutlet weak var broadcastOnSwitch: UISwitch!
    @IBOutlet weak var broadcastInfoLabel: UILabel!
    @IBOutlet weak var doneButton: CurvedButton!
    
    static func new(mode: HomeEditSsidPwdViewControllerMode,
                    completion: @escaping (String, HomeEditSsidPwdViewControllerMode) -> Void) -> HomeEditSsidPwdViewController {
        let vc = UIStoryboard(name: StoryboardNames.WiFiSettings.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: "HomeEditSsidPwdViewController") as! HomeEditSsidPwdViewController
        vc.completion = completion
        vc.vm = HomeEditSsidPwdViewModel(mode: mode)
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setInfoLabelText()
        setTextField()
        showHideBroadcastField()
        if let isOn = vm?.broadcastSwitchIsOn {
            broadcastOnSwitch.isOn = isOn
        }
        
        textEntryField.textField.text = vm!.initialText
        textEntryField.textField.clearButtonMode = .whileEditing

        title = vm?.title
        
        vm?.addAsObserver(observer: { type in
            self.updateUiForModelUpdate(type: type)
        })
    }
    
    private func updateUiForModelUpdate(type: ViewModelUpdateType?) {
        guard let type = type else {
            return
        }

        switch type {
        case .dataModelUpdated:
            break
        case .sendingData:
            showWorkingAlert(show: true)
            break
        case .sendingDataSuccess:
            showWorkingAlert(show: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.completion(self.textEntryField.textField.text!, self.vm!.mode)
                self.dismiss(animated: true)
            }
            
            break
        case .sendingDataFailed(let string):
            showWorkingAlert(show: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAlert(with: "Sending Failed", message: string)
            }
            break
        case .noChange:
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        if let errors = vm?.validationErrors(t: textEntryField.textField.text ?? "") {
            showAlert(with: "Validation error", message: errors)
            
            return
        }
        
        vm!.sendUpdate(t: textEntryField.textField.text!,
                       hideSsid: !broadcastOnSwitch.isOn)
    }
    
    override func setTheme() {
        let navbarColor = cm.background2
        setTitleItemBar(color: navbarColor, transparent: false)
        
        infoLabel.font = FontManager.regular(size: 13)
        broadcastInfoLabel.font = FontManager.regular(size: 13)
        infoLabel.textColor = InterfaceManager.shared.cm.text2.colorForAppearance
        broadcastInfoLabel.textColor = InterfaceManager.shared.cm.text2.colorForAppearance
        
        doneButton.backgroundColor = cm.themeTint.colorForAppearance
        doneButton.setTitleColor(cm.textWhite.colorForAppearance, for: .normal)
    }
    
    private func setInfoLabelText() {
        if vm!.mode == .ssid || vm!.mode == .guestSsid {
            infoLabel.text = "Your Wi-Fi name must be between 6 and 32 characters and can not contain special characters.".localized()
            return
        }
        
        infoLabel.text = "Users will be able to join your network using this password. Your password must be at least 8 characters long. For your security, please avoid passwords that are easy to guess such as \"password\" or \"12345678\"".localized()
    }
    
    private func setTextField() {
        if vm!.mode == .ssid || vm!.mode == .guestSsid {
            textEntryField.infoLabel.text = "Wi-Fi Name"
            return
        }
        
        textEntryField.infoLabel.text = "Password"
    }
    
    private func showHideBroadcastField() {
        if vm!.mode == .pwd || vm!.mode == .guestPwd {
            broadcastView.isHidden = true
            dividerView.isHidden = true
        }
    }
}





// MARK: - View Model
class HomeEditSsidPwdViewModel: HomeUserBaseViewModel {
    let mode: HomeEditSsidPwdViewController.HomeEditSsidPwdViewControllerMode
    var aps = HomeWifiAps()
    
    init(mode: HomeEditSsidPwdViewController.HomeEditSsidPwdViewControllerMode) {
        self.mode = mode
    }
    
    var initialText: String {
        switch mode {
        case .ssid:
            return aps.primaryAp.ssid
        case .pwd:
            return aps.primaryAp.pass
        case .guestSsid:
            return aps.guestAp.ssid
        case .guestPwd:
            return aps.guestAp.pass
        }
    }

    /// Initial state based on the config. Nil for passwords
    var broadcastSwitchIsOn: Bool? {
        switch mode {
        case .ssid:
            return !aps.primaryAp.hidden
        case .guestSsid:
            return !aps.guestAp.hidden
        default:
            return nil
        }
    }

    var title: String {
        if mode == .ssid || mode == .pwd {
            return "Primary Network"
        }

        return "Guest Network"
    }
    
    func validationErrors(t: String) -> String? {
        if mode == .ssid || mode == .guestSsid {
            let r = SSIDNamePasswordValidation.ssidNameValid(str: t)
            if r.0 {
                return nil
            }
            
            return r.1
        }
        else { // Pwd
            var ssid = aps.primaryAp.ssid
            if mode == .guestPwd {
                ssid = aps.guestAp.ssid
            }

            let r = SSIDNamePasswordValidation.passwordValid(passString: t, ssid: ssid)
            if r.0 {
                return nil
            }
            
            return r.1
        }
    }
    
    func sendUpdate(t: String, hideSsid: Bool) {
        guard var config = HubDataModel.shared.baseDataModel!.meshAPConfig else {
            informObserversOfChange(type: .sendingDataFailed("No Data model"))
            return
        }

        switch mode {
        case .ssid:
            aps.primaryAp.ssid = t
            aps.primaryAp.hidden = hideSsid
            aps.primaryAp5Ghz.ssid = t
            aps.primaryAp5Ghz.hidden = hideSsid
            break
        case .pwd:
            aps.primaryAp.pass = t
            aps.primaryAp5Ghz.pass = t
            break
        case .guestSsid:
            aps.guestAp.ssid = t
            aps.guestAp.hidden = hideSsid
            aps.guestAp5Ghz.ssid = t
            aps.guestAp5Ghz.hidden = hideSsid
            break
        case .guestPwd:
            aps.guestAp.pass = t
            aps.guestAp5Ghz.pass = t
            break
        }

        let primaryIndex = aps.primaryApIndex
        let guestIndex = aps.guestApIndex

        let primaryIndex5Ghz = aps.primaryAp5GhzIndex
        let guestIndex5Ghz = aps.guestAp5GhzIndex

        if mode.isPrimary {
            switch primaryIndex {
            case 0:
                config.ap_1_1 = aps.primaryAp
                break
            case 1:
                config.ap_1_2 = aps.primaryAp
                break
            case 2:
                config.ap_1_3 = aps.primaryAp
                break
            case 3:
                config.ap_1_4 = aps.primaryAp
                break
            case 4:
                config.ap_1_5 = aps.primaryAp
                break
            case 5:
                config.ap_1_6 = aps.primaryAp
                break
            default:
                break
            }

            switch primaryIndex5Ghz {
            case 0:
                config.ap_2_1 = aps.primaryAp5Ghz
                break
            case 1:
                config.ap_2_2 = aps.primaryAp5Ghz
                break
            case 2:
                config.ap_2_3 = aps.primaryAp5Ghz
                break
            case 3:
                config.ap_2_4 = aps.primaryAp5Ghz
                break
            case 4:
                config.ap_2_5 = aps.primaryAp5Ghz
                break
            case 5:
                config.ap_2_6 = aps.primaryAp5Ghz
                break
            default:
                break
            }
        }
        else {
            switch guestIndex {
            case 0:
                config.ap_1_1 = aps.guestAp
                break
            case 1:
                config.ap_1_2 = aps.guestAp
                break
            case 2:
                config.ap_1_3 = aps.guestAp
                break
            case 3:
                config.ap_1_4 = aps.guestAp
                break
            case 4:
                config.ap_1_5 = aps.guestAp
                break
            case 5:
                config.ap_1_6 = aps.guestAp
                break
            default:
                break
            }

            switch guestIndex5Ghz {
            case 0:
                config.ap_2_1 = aps.guestAp5Ghz
                break
            case 1:
                config.ap_2_2 = aps.guestAp5Ghz
                break
            case 2:
                config.ap_2_3 = aps.guestAp5Ghz
                break
            case 3:
                config.ap_2_4 = aps.guestAp5Ghz
                break
            case 4:
                config.ap_2_5 = aps.guestAp5Ghz
                break
            case 5:
                config.ap_2_6 = aps.guestAp5Ghz
                break
            default:
                break
            }
        }

        if config.hasConfigChanged() {
            informObserversOfChange(type: .sendingData)
            sendConfig(config: config)
            return
        }

        // If not change then just update the model and return
        informObserversOfChange(type: .noChange)
    }
}
