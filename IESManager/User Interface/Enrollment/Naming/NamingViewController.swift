//
//  NamingViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/10/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

protocol NamingDeviceMeshDelegate {
    func didNameDevice(name: String, meshesAvailable: [VHMesh], groupId: String)
    func didNameMesh(name: String)
}

fileprivate enum NamingViewError: Error {
    case emptyName
    case invalidChar
    case notAvailable
    case noFirstAlphaChar
    case tooLong
    
    var value: String {
        switch self {
        case .emptyName:
            return "Please enter a name".localized()
        case .invalidChar:
            return "Only letters, numbers, _ and - are allowed".localized()
        case .notAvailable:
            return "Name not available. Please use a different name".localized()
        case .noFirstAlphaChar:
            return "Names should begin with an alphabet".localized()
        case .tooLong:
            return "Names should be under 32 characters".localized()
        }
    }
}

class NamingViewController: VUIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .advanced_veeahub_settings
    var scrollView: UIScrollView!
    var fieldView: TextFieldWithDetail!
    var errorMessageLabel: UILabel!
    var continueButton: VUIFlatButton!
    
    var currentName: String = ""
    var delegate: NamingDeviceMeshDelegate?
    
    var viewModel: NamingViewViewModel!
    private var nameDialog: UIView?

    convenience init(vm: NamingViewViewModel) {
        self.init()
        self.viewModel = vm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.viewModel.model!.vcTitle
        self.removeBackButtonTitle()
        
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollVerticalWithDismissStyle(scrollView)
        scrollView.addOffset(UIConstants.Margin.top)
        self.view.addSubview(scrollView)
        
        // Title
        let titleView = TitleViewWithImage(icon: UIImage(named: viewModel.model.icon),title: self.viewModel.model.title, subtext: self.viewModel.model.details)
        scrollView.push(titleView)
        scrollView.addOffset(UIConstants.Margin.side * 2)
        
        // Textfield
        self.currentName = self.nameGenerator()
        fieldView = TextFieldWithDetail(detail: "Name".localized(), text: self.currentName)
        fieldView.textField.text = self.currentName
        fieldView.textfieldDelegate = self
        fieldView.textField.accessibility(config: AccessibilityConfigurations.textFieldNameHub)
        scrollView.push(fieldView)
        scrollView.addOffset(20)
        
        // Error Label
        errorMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIConstants.contentWidth, height: 0))
        errorMessageLabel.text = "Note: Tap on the default name to change"
        darkGrayLabelStyle(errorMessageLabel)
        centerStyle(errorMessageLabel)
        self.errorMessageLabel.alpha = 1
        self.errorMessageLabel.frame.size.width = UIConstants.contentWidth
        sizeToFitStyle(errorMessageLabel)
        self.errorMessageLabel.centerInView(superView: self.scrollView, mode: .horizontal)
        scrollView.push(errorMessageLabel)
        scrollView.addOffset(UIConstants.Margin.side * 2)
        
        // Continue Button
        continueButton = VUIFlatButton(frame: CGRect(x: UIConstants.Margin.side, y: (UIConstants.Margin.side*2), width: UIConstants.contentWidth, height: 40), type: .green, title: "Continue".localized())

        continueButton.accessibility(config: AccessibilityConfigurations.buttonNameContinue)

        continueButton.addTarget(self, action: #selector(NamingViewController.validateName), for: .touchUpInside)
        self.scrollView.push(continueButton)
        notifyOfHardwareLimitations()
        recordScreenAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            if  self.nameDialog != nil{
                self.nameDialog?.fadeOut {
                    self.nameDialog?.removeFromSuperview()
                }
            }
        }
    }

    // VHM-1571: [iOS Android] VHM should warn the user when adding a 05 unit as MEN
    private func notifyOfHardwareLimitations() {
        if viewModel.namingType == .mesh {
            if let info = delegate as? EnrollmentFlowCoordinator {
                if let result = MeshHardwareIncompatability.createMeshWith(men: info.enrollmentData.hardwareModel) {
                    showInfoAlert(title: "Warning".localized(),
                                  message: result.message)
                }
            }
        }
    }

    func updateErrorLabel(with text: String) {
        if !text.isEmpty {
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.error)
        }
        
        self.errorMessageLabel.alpha = 0
        self.errorMessageLabel.text = text
        self.errorMessageLabel.frame.size.width = UIConstants.contentWidth
        sizeToFitStyle(errorMessageLabel)
        self.errorMessageLabel.centerInView(superView: self.scrollView, mode: .horizontal)
        
        UIView.animate(withDuration: 0.2) {
            self.errorMessageLabel.alpha = 1.0
        }
    }
    
    @objc func validateName() {
        if let name_ = self.fieldView.textField.text, !name_.isEmpty {
            self.currentName = name_
        }
        if self.currentName == "" {
            self.updateErrorLabel(with: NamingViewError.emptyName.value)
            return
        }
        
        if viewModel.namingType == .device {
            self.checkDeviceNameAvailability()
        } else {
            self.checkMeshNameAvailability()
        }
    }
    
    func nameGenerator() -> String {
        if let enrollmentFlowCord = delegate as? EnrollmentFlowCoordinator {
            let serial = enrollmentFlowCord.enrollmentData.code
            return self.viewModel.nameGenerator(serial: serial)
        }

        return self.viewModel.nameGenerator(serial: nil)
    }
    
    // MARK: - Network calls
    private func checkDeviceNameAvailability() {
        continueButton.showActivity()
        EnrollmentService.checkDeviceName(groupId : self.viewModel.groupId, name: self.currentName, success: { (meshes, owner) in
            self.delegate?.didNameDevice(name: self.currentName,meshesAvailable: meshes, groupId: owner)
            self.continueButton.stopActivity()
        }) { (err) in
            self.continueButton.stopActivity()
            showAlert(with: "Error".localized(), message: err)
        }errData: { (errorMeta) in
            self.showErrorHandlingAlert(title: errorMeta.title ?? "", message: errorMeta.message ?? "", suggestions: errorMeta.suggestions ?? [])
        }
    }
    
    private func checkMeshNameAvailability() {
        continueButton.showActivity()
        EnrollmentService.checkMeshName(groupId : self.viewModel.groupId, name: self.currentName, success: {
            self.delegate?.didNameMesh(name: self.currentName)
            self.continueButton.stopActivity()
        }) { (err) in
            self.continueButton.stopActivity()
            if let enrollmentFlowCord = self.delegate as? EnrollmentFlowCoordinator {
                if let meshes = enrollmentFlowCord.meshes {
                    for mesh in meshes {
                        if mesh.name.lowercased() == self.currentName.lowercased() {
                            self.showDuplicateNameDialog(name: self.currentName, mesh: mesh)
                            
                            return
                        }
                    }
                }
            }
            showAlert(with: "Error".localized(), message: err)
        }errData: { (errorMeta) in
        }
    }
    
    private func showDuplicateNameDialog(name: String, mesh: VHMesh) {
        let message = "The name ".localized() + name + " is already in use. Do you want to add this hub to ".localized() + name + "?"
        
        let alert = UIAlertController(title: "Mesh name already in use".localized(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "\("Add to".localized()) \(name)", style: .destructive, handler: { (action) in
            alert.close()
            
             if let enrollmentFlowCord = self.delegate as? EnrollmentFlowCoordinator {
                enrollmentFlowCord.didChooseMesh(with: mesh)
            }
             else {
                showAlert(with: "Error".localized(), message: "Could not set the mesh".localized())
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { (_) in
            alert.close()
        }))
        alert.show()
    }
    
    private func tappedOnTextFieldToNameVeeahub() {
            if self.nameDialog != nil {
                self.nameDialog?.removeFromSuperview()
            }
        
            let name = self.currentName
            let message = "Names should be under 32 characters, begin with an alphabetic character. Only letters, numbers, _ and - are allowed.".localized()
            var title = "Enter your custom name of your Veeahub"
            if self.viewModel.model!.vcTitle.localized() == "Name Mesh".localized() {
                title = "Enter a custom name of your mesh"
            }
            let dialogView = NamingDialogView(title: title.localized(),
                                              message: message,
                                              textFieldText: name) { okTapped, newName in
                if okTapped && name != newName {
                    self.fieldView.textField.text = newName
                    self.validateName()
                }
                
                DispatchQueue.main.async {
                    self.nameDialog?.fadeOut {
                        self.nameDialog?.removeFromSuperview()
                    }
                }
            }

            self.nameDialog = SwiftUIUIView<NamingDialogView>(view: dialogView,
                                                                requireSelfSizing: true).make()
            nameDialog?.alpha = 0
            if let window = UIApplication.shared.windows.filter ({$0.isKeyWindow}).first {
                self.nameDialog!.frame = window.frame
                window.addSubview(nameDialog!)
                nameDialog?.fadeIn {}
            }
    }
}


// MARK: - UITextFieldDelegate
extension NamingViewController: UITextFieldDelegate {
    private struct AcceptableChacracters {
        static let allowed = "_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.tappedOnTextFieldToNameVeeahub()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text?.count ?? 0) == 32 && !string.isEmpty {
            self.updateErrorLabel(with: NamingViewError.tooLong.value)
            return false
        }
        
        if !self.viewModel.checkIfFirstCharIsAlpha(textFieldText: textField.text, string: string) {
            self.updateErrorLabel(with: NamingViewError.noFirstAlphaChar.value)
            return false
            
        }
        let components = string.components(separatedBy: CharacterSet(charactersIn: AcceptableChacracters.allowed).inverted)
        let filtered = components.joined(separator: "")
        
        if string == filtered {
            //Update error message if there is no error
            self.updateErrorLabel(with: "")
            return true
        }
        
        self.updateErrorLabel(with: NamingViewError.invalidChar.value)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
