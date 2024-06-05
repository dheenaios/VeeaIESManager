//
//  SelectRealmViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 26/11/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class SelectRealmViewController: UIViewController {
    
    private let vm = SelectRealmViewModel()
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var addNewRealmDisclosureView: UIView!
    @IBOutlet private weak var addNewRealmView: UIView!
    
    var loginflowDelegate: LoginFlowCoordinatorDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        setTheme()
        title = "Select organization".localized()

        newRealmOptionDisclosureView()
        newRealmEmbelishments()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        // Update the navbar globally and locally
        updateNavBarWithDefaultColors()
        // To be implemented in the subclass
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func newRealmOptionDisclosureView() {
        let bottomDisclosure = UITableViewCell()
        bottomDisclosure.frame = addNewRealmDisclosureView.bounds
        bottomDisclosure.accessoryType = .disclosureIndicator
        bottomDisclosure.isUserInteractionEnabled = false
        addNewRealmDisclosureView.addSubview(bottomDisclosure)
    }
    
    private func newRealmEmbelishments() {
        let color = UIColor.lightGray.cgColor
        let curve: CGFloat = 5.0
        let width: CGFloat = 0.5
        
        addNewRealmView.layer.cornerRadius = curve
        addNewRealmView.layer.borderWidth = width
        addNewRealmView.layer.borderColor = color
        addNewRealmView.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? NewRealmViewController else { return }
        vc.loginflowDelegate = loginflowDelegate
    }
}

extension SelectRealmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        VeeaRealmsManager.selectedRealm = vm.selectedRealm(at: indexPath.row).name
        AuthorisationManager.shared.reset()
        
        AuthorisationManager.shared.delegate = self
        AuthorisationManager.shared.discoverConfiguration()
    }
}

extension SelectRealmViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.usersRealmsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RealmCell
        let isDefault = indexPath.row == 0
        cell.configure(model: vm.selectedRealm(at: indexPath.row),
                       isDefault: isDefault)
        
        return cell
    }
}

extension SelectRealmViewController: AuthorisationDelegate {
    func configDiscoveryCompleted(success: (SuccessAndOptionalMessage)) {
        if !success.0 {
            showErrorInfoMessage(message: success.1 ?? "No info".localized())
            return
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        AuthorisationManager.shared.requestLogin(hostViewController:
                                                    self, authFlowSessionManager: appDelegate)
    }
    
    func loginRequestResult(success: (SuccessAndOptionalMessage)) {
        if !success.0 {
            showErrorInfoMessage(message: success.1 ?? "\("Log in failed because".localized()) \(success.1 ?? "\("of an unknown issue".localized())")")
            return
        }
        
        self.loginflowDelegate?.loginComplete()
    }
    
    func gotUserInfoResult(success: (Bool, String?, VHUser?)) {}
}

class RealmCell: UITableViewCell {
    @IBOutlet weak var veeaImageView: UIImageView!
    @IBOutlet weak var realmTitle: UILabel!
    @IBOutlet weak var disclosureContainerView: UIView!
    @IBOutlet weak var backingView: UIView!
    
    private var setup = false
    
    
    func configure(model: VeeaRealmsManager.RealmDetails, isDefault: Bool) {
        addEmbelishments()
        realmTitle.text = isDefault ? model.name.appending(" (default)") : model.name
        
        var globe = UIImage(named: "app_server_grey")
        globe = UIImage(systemName: "globe")
        
        let image = isDefault ? UIImage(named: "veeaLogo") : globe
        let color = isDefault ? UIColor(named: "purpleBack") : UIColor.lightGray
        
        veeaImageView.backgroundColor = color
        veeaImageView.image = image
    }
    
    func addEmbelishments() {
        if setup {
           return
        }
        
        setup = true
        let color = UIColor.lightGray.cgColor
        let curve: CGFloat = 5.0
        let width: CGFloat = 0.5
        
        backingView.layer.cornerRadius = curve
        backingView.layer.borderWidth = width
        backingView.layer.borderColor = color
        backingView.layer.masksToBounds = true
        
        veeaImageView.layer.cornerRadius = 2.0
        veeaImageView.layer.masksToBounds = true
        veeaImageView.tintColor = .white
    }
}
