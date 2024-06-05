//
//  DefaultWifiViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 05/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class DefaultWifiViewModel {
    
    // TITLE INFO
    let titleText = "Set your Wi-Fi name and password".localized()
    let subTitleText = "Set a Wi-Fi name (SSID) and password to use your VeeaHub as a Wi-Fi access point. All VeeaHubs added to the same mesh will initially carry the same SSID. You can set or change the SSID and security mode later from the Wi-Fi setting. Scroll to the bottom if you want to skip it.".localized()
    
    
    var skipLabelAttributedText: NSAttributedString {
        get {
            let topRowFont = FontManager.regular(size: 13)
            let bottomRowFont = FontManager.regular(size: 13)
            
            let fontColor = UIColor.label
            let skipItColor = UIColor.blue
            
            let topRowAttr: [NSAttributedString.Key : Any] = [
                .foregroundColor: fontColor,
                .font: topRowFont
            ]
            
            let skipItAtter: [NSAttributedString.Key : Any] = [
                .foregroundColor: skipItColor,
                .font: topRowFont
            ]
            
            let bottomRowAttr: [NSAttributedString.Key : Any] = [
                .foregroundColor: fontColor,
                .font: bottomRowFont
            ]
            
            let topLine = NSMutableAttributedString(string: "Don't want to set Wi-Fi? ".localized())
            topLine.addAttributes(topRowAttr, range: NSRange(location: 0, length: topLine.length))
            
            let skipIt = NSMutableAttributedString(string: "Skip it")
            skipIt.addAttributes(skipItAtter, range: NSRange(location: 0, length: skipIt.length))
            
            let bottomLine = NSMutableAttributedString(string: "\nYou can always change this later.\n\n".localized())
            bottomLine.addAttributes(bottomRowAttr, range: NSRange(location: 0, length: bottomLine.length))
            
            
            let attrStr = NSMutableAttributedString(attributedString: topLine)
            attrStr.append(skipIt)
            attrStr.append(bottomLine)
            
            return attrStr
        }
    }
    
    // TEXT FIELD INFO
    
   
    
    
    let ssidFieldTitle = "Name Wi-Fi Network".localized()
    let ssidFieldPlaceHolder = "SSID name".localized()
    let ssidFieldText = ""
    
    let ssidFieldTitle1 = "Network Name(SSID)".localized()
    let ssidFieldPlaceHolder1 = "required".localized()
    
    let passwordFieldTitle = "Wi-Fi Password".localized()
    let passwordFieldPlaceHolder = "At least 8 characters.".localized()
    let passwordFieldText = ""
    
    let passwordFieldTitle1 = "Password".localized()
    
    let confirmPasswordFieldTitle = "Confirm Wi-Fi Password".localized()
    let confirmPasswordFieldPlaceHolder = "Reenter your password".localized()
    let confirmPasswordFieldText = ""
    
    let confirmPasswordFieldTitle1 = "Password(Confirm)".localized()
    
    public func validateFields(ssid: KeyValueTextField,
                               password: KeyValueTextField,
                               confirm: KeyValueTextField) -> (Bool, String) {
        let ssidStr = ssid.text
        let passStr = password.text
        let confStr = confirm.text
        
        if ssidStr.isEmpty || passStr.isEmpty || confStr.isEmpty {
            return (false, "Some fields are empty".localized())
        }
        else if passStr != confStr {
            return (false, "Please check that passwords match.".localized())
        }
        else if !ssid.contentsValid {
            return (false, "Please make sure that your wifi name has at least 1 to 32 characters and no spaces. Valid characters are 0–9, a-z, A-Z, and special characters: ! # @ $ ( ) – ‘. , / ; _".localized())
        }
        else if !password.contentsValid {
            let message = "Please make sure that your wifi password has at least 8 to 64 characters and no spaces. Valid characters are 0–9, a-z, A-Z, and special characters:  ! # @ $ ( ) – ‘. , / ; _".localized()
            
            return (false, message)
        }
        
        return (true, "")
    }
    
    public func validateFields(ssid: CurvedTextEntryField,
                               password: CurvedTextEntryField,
                               confirm: CurvedTextEntryField,
                               ssid_5: CurvedTextEntryField,
                               password_5: CurvedTextEntryField,
                               confirm_5: CurvedTextEntryField,optedForBoth:Bool) -> (Bool, String) {
        let ssidStr = ssid.textField.text ?? ""
        let passStr = password.textField.text ?? ""
        let confStr = confirm.textField.text ?? ""
        
        if optedForBoth {
            return checkingFields(ssid: ssid, pass: password, confirm: confirm)
        }
        else {
            let ssidStr_5 = ssid_5.textField.text ?? ""
            let passStr_5 = password_5.textField.text ?? ""
            let confStr_5 = confirm_5.textField.text ?? ""
            
            if ssidStr.isEmpty || passStr.isEmpty || confStr.isEmpty {
                return (false, "Some fields are empty".localized())
            }
            else if passStr != confStr {
                return (false, "Please check that passwords match.".localized())
            }
            else if !ssid.contentsValid {
                return (false, "Please make sure that your wifi name has at least 1 to 32 characters and no spaces. Valid characters are 0–9, a-z, A-Z, and special characters: ! # @ $ ( ) – ‘. , / ; _".localized())
            }
            else if !password.contentsValid {
                let message = "Please make sure that your wifi password has at least 8 to 64 characters and no spaces. Valid characters are 0–9, a-z, A-Z, and special characters:  ! # @ $ ( ) – ‘. , / ; _".localized()
                
                return (false, message)
            }
            else if ssidStr_5.isEmpty || passStr_5.isEmpty || confStr_5.isEmpty {
                return (false, "Some fields are empty".localized())
            }
            else if passStr_5 != confStr_5 {
                return (false, "Please check that passwords match.".localized())
            }
            else if !ssid_5.contentsValid {
                return (false, "Please make sure that your wifi name has at least 1 to 32 characters and no spaces. Valid characters are 0–9, a-z, A-Z, and special characters: ! # @ $ ( ) – ‘. , / ; _".localized())
            }
            else if !password_5.contentsValid {
                let message = "Please make sure that your wifi password has at least 8 to 64 characters and no spaces. Valid characters are 0–9, a-z, A-Z, and special characters:  ! # @ $ ( ) – ‘. , / ; _".localized()
                
                return (false, message)
            }
        }
        return (true, "")
    }
    
    func checkingFields(ssid:CurvedTextEntryField,pass:CurvedTextEntryField,confirm:CurvedTextEntryField) -> (Bool, String){
        
        let ssidStr = ssid.textField.text ?? ""
        let passStr = pass.textField.text ?? ""
        let confStr = confirm.textField.text ?? ""
        
        if ssidStr.isEmpty || passStr.isEmpty || confStr.isEmpty {
            return (false, "Some fields are empty".localized())
        }
        else if passStr != confStr {
            return (false, "Please check that passwords match.".localized())
        }
        else if !ssid.contentsValid {
            return (false, "Please make sure that your wifi name has at least 1 to 32 characters and no spaces. Valid characters are 0–9, a-z, A-Z, and special characters: ! # @ $ ( ) – ‘. , / ; _".localized())
        }
        else if !pass.contentsValid {
            let message = "Please make sure that your wifi password has at least 8 to 64 characters and no spaces. Valid characters are 0–9, a-z, A-Z, and special characters:  ! # @ $ ( ) – ‘. , / ; _".localized()
            
            return (false, message)
        }
        
        return (true, "")
    }
}
