//
//  MeshUpdateViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 23/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class MeshUpdateViewController: BaseConfigViewController {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var updates: [PackagesWithUpdates]?
    private var meshUUID: String?
    private var menSerial: String?
    private var groupId: String?
    
    func configure(groupId: String,
                   meshUUID: String,
                   menSerial: String,
                   packagesToUpdate: [PackagesWithUpdates]) {
        self.groupId = groupId
        self.meshUUID = meshUUID
        self.menSerial = menSerial
        self.updates = packagesToUpdate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabelText()
        // Do any additional setup after loading the view.
    }
    
    private func setLabelText() {
        guard let updates = updates else {
            infoLabel.text = ""
            return
        }
        
        if updates.count == 1 {
            infoLabel.text = "There is 1 software update available for this mesh.".localized()
            return
        }
        
        let start = "There are".localized()
        let end = "software updates available for this mesh.".localized()
        infoLabel.text = "\(start) \(updates.count) \(end)"
    }
    
    @IBAction func updateAllTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Request Update",
                                      message: "The update may take up to an hour, during which time your Mesh and Veea Hubs may not be usable. Are you sure you wish to continue?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(),
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "Update".localized(),
                                      style: .destructive, handler: { action in
            self.makeUpdateRequest()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func makeUpdateRequest() {
        updateIndicator.labelText = "Requesting update".localized()
        updateIndicator.updateIndicator(state: .uploading, host: self)
        
        
        UpdateRequestController.requestUpdate(meshUUID: meshUUID!,
                                              packagesToUpdate: updates!) { success, error in
            if !success {
                self.handleErrors(error: error)
                return
            }
            
            self.updateIndicator.updateIndicator(state: .completeWithSuccess,
                                                 host: self)
        }
    }
    
    private func handleErrors(error: MeshUpdateError?) {
        updateIndicator.updateIndicator(state: .completeWithError, host: self)
        
        guard let error = error else {
            showAlert(with: "Update request failed", message: "Please try again later", actions: nil)
            return
        }
        
        var errorMessage = ""
        switch error {
        case .notAuthorised:
            errorMessage = "Verification issue. Please logout and then back in. Then try again"
        case .noData(let message):
            errorMessage = "The service returned no data. \(message)"
        case .errorInResponse(_):
            errorMessage = "The service returned an unexpected response"
        case .unsuccessfulHttpResponse(let httpCode, let message):
            errorMessage = "\(message) - code: \(httpCode)"
        case .badlyFormedJson(_):
            errorMessage = "The service returned an unexpected response"
        case .notFound:
            errorMessage = "The service returned an unexpected response"
        case .partialResponse(_):
            errorMessage = "Some update requests were not successful. Please try again later."
        }
        
        showAlert(with: "Error".localized(), message: errorMessage) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension MeshUpdateViewController: UITableViewDelegate {
    
}

extension MeshUpdateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UpdatePackageCell
        let model = updates![indexPath.row]
        cell.configure(title: model.title,
                       originalVersion: model.currentVersion,
                       updateVersion: model.newVersion)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        guard let updates = updates else { return 0 }
        return updates.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}

class UpdatePackageCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    func configure(title: String,
                   originalVersion: String,
                   updateVersion: String) {
        titleLabel.text = title
        let subTitle = "\(originalVersion) → \(updateVersion)"
        subTitleLabel.text = subTitle
    }
}
