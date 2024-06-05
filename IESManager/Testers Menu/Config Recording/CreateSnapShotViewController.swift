//
//  CreateSnapShotViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 22/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit


class CreateSnapShotViewController: UIViewController {
    
    private var snapshot: ConfigurationSnapShot?
    
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create a snapshot"
        updatePreview()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createSnapshotTapped(_ sender: Any) {
        descriptionField.resignFirstResponder()
        createSnapshot()
    }
    

    @IBAction func saveOrShareTapped(_ sender: Any) {
        shareFile()
    }
}

// MARK: - Create snapshot
extension CreateSnapShotViewController {
    private func createSnapshot() {
        guard let bdm = HubDataModel.shared.baseDataModel else {
            textView.text = "No base data model.\nPlease make sure the VHM is connected to a hub and data has been downloaded."
            
            return
        }
        
        snapshot = ConfigurationSnapShot.init(baseModel: bdm.originalJson,
                                                  optionalModel: HubDataModel.shared.optionalAppDetails?.originalJson)
        snapshot?.snapShotDescription = descriptionField.text
        updatePreview()
    }
    
    private func updatePreview() {
        guard let model = snapshot else {
            textView.text = ""
            return
        }
        
        textView.text = model.snapshotJsonString()
        //print(model.snapshotJsonString())
    }
}

// MARK: - Save and Share
extension CreateSnapShotViewController {
    func shareFile() {
        guard let snapshot = snapshot?.snapShotJsonDictionary() else {
            textView.text = "Error generating snapshot info"
            return
        }
        
        var connectionName = "MAS Connection"
        
        if let connection = HubDataModel.shared.connectedVeeaHub as? VeeaHubConnection {
            connectionName = connection.hubDisplayName
        }
        if let connection = HubDataModel.shared.connectedVeeaHub as? MasConnection {
            connectionName = "MAS Connection to Hub ID \(connection.nodeId)"
        }
        
        let df = DateFormatter.iso8601Full
        let fileName = "\(df.string(from: Date())) - Snapshot for \(connectionName).json"
        
        guard let url = FileHelper.saveDictionary(dict: snapshot, named: fileName) else {
            textView.text = "Error saving the snapshot"
            
            return
        }

        let activity = UIActivityViewController.init(activityItems: [url], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activity, animated: true, completion: nil)
    }
}
