//
//  ManageVeeaHubsViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 18/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class ManageVeeaHubsViewController: HomeUserBaseViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .home_manage_veeahubs_screen

    fileprivate var connectionProgressAlert: ConnectionProgressAlert?
    
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var addNewDeviceButton: UIButton!
    
    private var searchBarController: UISearchController!
    private var vm: ManageVeeaHubsViewModel!
    
    
    static func new(mesh: VHMesh,
                    meshDetailViewModel: MeshDetailViewModel) -> ManageVeeaHubsViewController {
        let vc = UIStoryboard(name: StoryboardNames.ManageVeeaHubs.rawValue, bundle: nil).instantiateInitialViewController() as! ManageVeeaHubsViewController
        vc.vm = ManageVeeaHubsViewModel(mesh: mesh,
                                        meshDetailViewModel: meshDetailViewModel)
        vc.vm.delegate = vc
        
        return vc
    }
    
    override func setTheme() {
        updateNavBarWithCustomColors(color: InterfaceManager.shared.cm.background2,
                                     transparent: true)
        view.backgroundColor = InterfaceManager.shared.cm.background2.colorForAppearance
        
    addNewDeviceButton.titleLabel?.font = FontManager.medium(size: 17)
        addNewDeviceButton.titleLabel?.textColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSearchController()
        addNavBarAddButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()

        DispatchQueue.main.async {
            self.navigationController?.navigationBar.sizeToFit()
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // If back is being tapped, check we have the MEN View model
        if self.isMovingFromParent {
            vm.checkDataModelIsMen()
        }
    }

    private func addNavBarAddButton() {

        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addNewHub))

        self.navigationItem.rightBarButtonItem  = addButton
    }

    private func addSearchController() {
        self.searchBarController = addSearchAndCreateController(placeHolderText: "Search".localized(),
                                                                searchResultsUpdater: self,
                                                                hostNavigationItem: self.navigationItem)
        searchBarController.hidesNavigationBarDuringPresentation = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController!.navigationBar.sizeToFit()
    }
    
    @IBAction func addNewDeviceTapped(_ sender: Any) {
        addNewHub()
    }

    @objc func addNewHub() {
        let groupsViewModel = GroupsViewModel()
        showWorkingAlert(show: true)
        groupsViewModel.loadGroups {
            if let group = groupsViewModel.groups?.first {
                self.showWorkingAlert(show: false)

                // Give the working alert time to remove
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.pushToScan(group: group)
                }
            }
            else {
                self.handleErrorGettingUserDetails()
            }

        } error: { error in
            self.handleErrorGettingUserDetails()
        }
    }
    
    private func pushToScan(group: GroupModel) {
        self.navController.newEnrollment.group = group
        self.navController.newEnrollment.meshName = group.name
        let scanVc = ScanCodeViewController.new()
        self.navController.pushViewController(scanVc, animated: true)
    }
    
    private func handleErrorGettingUserDetails() {
        self.showWorkingAlert(show: false)
        showAlert(with: "Error", message: "Something went wrong. Please try logging in again") {
            self.navController.logout()
        }
    }
}

extension ManageVeeaHubsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat { 70 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if InternetConnectionMonitor.shared.connectivityStatus == .Disconnected {
            showAlert(with: "No connection".localized(),
                      message: "No connection. Please check your internet connection.".localized())

            return
        }

        let model = vm.nodeTableCellModelForIndex(indexPath.row)
        
        if model.healthState.data == .healthy {
            handleSelection(model: model)
            return
        }
        
        let vc = HomePreparingNodeViewController.new(nodeTableCellModel: model)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleSelection(model: NodeTableCellModel) {
        var style = UIAlertController.Style.actionSheet
        if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
            style = UIAlertController.Style.alert
        }

        let alert = UIAlertController(title: model.device.name, message: nil, preferredStyle: style)

        if model.healthState.data == .healthy {
            alert.addAction(UIAlertAction(title: "Reboot".localized(), style: .default, handler: { [weak self] action in
                let alert = UIAlertController(title: "Reboot?".localized(),
                                              message: "Are you sure you want to reboot this VeeaHub".localized(),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                alert.addAction(UIAlertAction(title: "Reboot".localized(), style: .destructive, handler: { [weak self] action in
                    self?.doReboot(model: model)
                }))
                self?.present(alert, animated: true)
            }))
        }

        alert.addAction(UIAlertAction(title: "About this VeeaHub".localized(), style: .default, handler: { [weak self] action in
            self?.loadNodeInfo(model: model)
        }))

        if model.healthState.data == .healthy {
            alert.addAction(UIAlertAction(title: "Advanced Settings".localized(), style: .default, handler: { [weak self] action in
                self?.showEnterpriseDashboard(model: model)
            }))
        }

        alert.addAction(UIAlertAction(title: "Remove".localized(), style: .destructive, handler: { [weak self] action in
            let alert = UIAlertController(title: "Remove VeeaHub?".localized(),
                                          message: "Are you sure you want to remove this VeeaHub".localized(),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            alert.addAction(UIAlertAction(title: "Remove".localized(), style: .destructive, handler: { [weak self] action in
                self?.vm.removeHub(model: model) { success, message in
                    self?.showWorkingAlert(show: false)
                    if success {
                        self?.vm.removeModel(model: model)
                    }
                    else { showAlert(with: "Error".localized(),
                                     message: message) }
                }
            }))
            self?.present(alert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        self.present(alert, animated: true)
    }

    private func loadNodeInfo(model: NodeTableCellModel) {
        vm.aboutThisVeeahHub(cellModel: model) { vc, errorString in
            if let errorString = errorString {
                showAlert(with: "Error", message: errorString)
                return
            }

            guard let vc = vc else { return }
            self.present(vc, animated: true)
        }
    }

    private func doReboot(model: NodeTableCellModel) {
        self.vm.rebootHub(model: model) {[weak self] success, message in
            if success { self?.showInfoMessage(message: message) }
            else { self?.showErrorInfoMessage(message: message) }
        }
    }
}

// MARK: - Connection to enterprise dashboard
extension ManageVeeaHubsViewController {
    private func showEnterpriseDashboard(model: NodeTableCellModel) {
        let connectionInfo = vm.getConnectionInfoForModel(model)
        makeConnection(connectionInfo: connectionInfo)
    }
    
    private func makeConnection(connectionInfo: ConnectionInfo) {
        HubDataModel.shared.snapShotInUse = false
        let hub = connectionInfo.veeaHub
        
        if connectionProgressAlert == nil {
            connectionProgressAlert = ConnectionProgressAlert.init(frame: self.view.frame)
        }
        
        connectionProgressAlert?.connectToHub(hub: hub, completion: { (success, message) in
            if success {
                if !HubDataModel.shared.isDataSetComplete {
                    self.makeConnection(connectionInfo: connectionInfo)
                    return
                }
                
                self.pushToTheDash(connection: connectionInfo)
            }
            else {
                self.showFailDialog()
                self.removeConnectionProgressAlert()
            }
        })
        
        connectionProgressAlert!.alpha = 0.0
        UIWindow.sceneWindow?.addSubview(connectionProgressAlert!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.connectionProgressAlert!.alpha = 1.0
        })
    }
    
    private func pushToTheDash(connection: ConnectionInfo?) {
        if let d = UIStoryboard(name: "Dash", bundle: nil)
            .instantiateViewController(withIdentifier: "DashViewController") as? DashViewController {
            d.connectionInfo = connection
            d.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(d, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    private func showFailDialog() {
        showAlert(with: "Connection Failed".localized(), message: "Please try again later".localized())
    }
    
    private func removeConnectionProgressAlert() {
        connectionProgressAlert?.tearDown()
        connectionProgressAlert = nil
    }
}

extension ManageVeeaHubsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        vm.numberOfDevices
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NameIndicatorSelectionCell
        cell.imageOptionView.backingView.backgroundColor = UIColor(named: "WhiteBlack")
        
        let cellModel = vm.deviceModelForIndex(indexPath.row)
        cell.configure(model: cellModel)
        
        return cell
    }
}

extension ManageVeeaHubsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        vm.searchTerm = text.lowercased()
        tableView.reloadData()
    }
}

extension ManageVeeaHubsViewController: MeshStateDelegate {
    func meshStateUpdated() {
        tableView.reloadData()

        // If there are no devices, move the user back to the enrollment page.
        if vm.numberOfDevices == 0 {
            self.navController.popToRootViewController(animated: true)
        }
    }
}
