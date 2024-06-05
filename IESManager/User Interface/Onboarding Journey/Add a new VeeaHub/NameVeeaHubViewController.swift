//
//  NameVeeaHubViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 23/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class NameVeeaHubViewController: OnboardingBaseViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private let vm = NameVeeaHubViewModel()
    
    static func new() -> NameVeeaHubViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserEnrollment.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: "NameVeeaHubViewController") as! NameVeeaHubViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Name VeeaHub".localized()
        // Do any additional setup after loading the view.
    }
    
    override func setTheme() {
        super.setTheme()
        infoLabel.textColor = cm.text1.colorForAppearance
        infoLabel.font = FontManager.bodyText
    }
}

extension NameVeeaHubViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        82
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt
                   indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if vm.optionIsCustom(index: indexPath.row) {
            Utils.showInputAlert(from: self, title: "Custom Location".localized(),
                                 message: "Enter a location".localized(),
                                 initialValue: "",
                                 okButtonText: "OK".localized()) { selection in
                self.selectedLocation(selection)
            }
            return
        }
        
        let selection = vm.options[indexPath.row].title
        selectedLocation(selection)
    }
    
    private func selectedLocation(_ location: String) {
        var name = location.replacingOccurrences(of: " ", with: "_")
        name.append("-\(navController.newEnrollment.defaultName!)")
        
        if !entryIsValid(name: name) {
            return
        }
        
        guard let groupId = navController.newEnrollment.group?.id else {
            showAlert(with: "Error".localized(),
                      message: "Error getting configuration details.\nPlease wait a moment and try again.".localized())
            
            return
        }
        
        showSpinner()
        
        EnrollmentService.checkDeviceName(groupId : groupId,
                                          name: name,
                                          success: { (meshes, owner) in
            self.updateEnrollmentDetails(name: name,
                                         owner: owner,
                                         meshes: meshes)
            self.removeSpinner()
            
            self.push(meshes: meshes)
        }) { (err) in
            showAlert(with: "Error".localized(), message: err)
            self.removeSpinner()
        } errData: { (errorMeta) in
            self.showErrorHandlingAlert(title: errorMeta.title ?? "", message: errorMeta.message ?? "", suggestions: errorMeta.suggestions ?? [])
        }
    }
    
    private func entryIsValid(name: String) -> Bool {
        if let errors = NameValidation.hubNameHasErrors(name: name) {
            showAlert(with: "Hub Naming Error", message: errors, actions: nil)
            
            return false
        }
        
        return true
    }
    
    private func push(meshes: [VHMesh]) {
        if meshes.isEmpty { // Then this is the first hub. Set the wifi
            navController.pushViewController(OnboardingWiFiSettingsViewController.new(), animated: true)
            return
        }
        
        guard let devices = meshes.first?.devices else { // First hub. Set the Wifi
            navController.pushViewController(OnboardingWiFiSettingsViewController.new(), animated: true)
            return
        }
        if devices.isEmpty { // First hub. Set the Wifi
            navController.pushViewController(OnboardingWiFiSettingsViewController.new(), animated: true)
        }
        else { // This is not the first hub, so we're done!
            sendAndShowComplete()
        }
    }
    
    private func updateEnrollmentDetails(name: String,
                                         owner: String,
                                         meshes: [VHMesh]) {
        navController.newEnrollment.name = name
        navController.newEnrollment.owner = owner
        
        if meshes.isEmpty {
            navController.newEnrollment.setMesh(type: .create,
                                                name: navController.newEnrollment.defaultMeshName!,
                                                meshId: "")
        }
        else {
            let mesh = meshes.first
            let meshName = mesh?.name ?? navController.newEnrollment.defaultMeshName!
            let meshId = mesh?.id ?? ""
            
            navController.newEnrollment.setMesh(type: .addTo,
                                                name: meshName,
                                                meshId: meshId)
        }
    }
}

extension NameVeeaHubViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        vm.options.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NameSelectionCell
        let model = vm.options[indexPath.row]
        cell.configure(model: model)
        
        return cell
    }
}
