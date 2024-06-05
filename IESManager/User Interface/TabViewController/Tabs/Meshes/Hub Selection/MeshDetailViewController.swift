//
//  MeshDetailViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/10/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking


class MeshDetailViewController: VUIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .mesh_details_screen

    
    var flowController: HubInteractionFlowController?
    
    private var vm: MeshDetailViewModel?
    
    private let refreshControl = UIRefreshControl()
    
    fileprivate var connectionProgressAlert: ConnectionProgressAlert?
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var healthPill: HealthPillView!
    @IBOutlet weak var updatePillContrainerView: UIView!
    @IBOutlet weak var updatePill: UpdateAvailablePillView!
    
    @IBOutlet weak var progressViewContainer: UIView!
    @IBOutlet weak var progressView: MeshUpdateProgressView!

    @IBOutlet weak var healthBillHeightConstraint: NSLayoutConstraint!
    private var renameDialog: UIView?
    
    // If we have just launched and the progress is 100% then we dont show the progress UI
    // As the update looks to have completed.
    // On other occasions we are still interested in the status
    private var firstProgressRequestAfterViewAppear = true
    
    convenience init(viewModel: MeshDetailViewModel) {
        self.init()
        setViewModel(viewModel: viewModel)
    }
    
    public func setViewModel(viewModel: MeshDetailViewModel) {
        vm = viewModel
        UserSettings.connectOnlyViaBeacon = true // Legacy option. Make sure both methods can be used
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        flowController?.currentViewController = self
        self.view.backgroundColor = .vBackgroundColor
        self.title = "VeeaHubs".localized()
        self.removeBackButtonTitle()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        self.tableView.refreshControl?.tintColor = .darkGray
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.addObservers()
        
        vm?.hostVC = self
        configureHealthPill()
        
        updatePill.observerTaps {
            self.updateTapped()
        }
        
        addSearchBar(placeHolderText: "Search",
                     searchResultsUpdater: self,
                     hostNavigationItem: nil)
        
        progressView.delegate = self
        registerForAppForgroundingNotifications()
        addMoreMenu()
    }

    @objc private func refreshData(_ sender: Any) {
        Task {
            await vm?.dispatchDataFetcher()
            await MainActor.run {
                self.refreshControl.endRefreshing()
                self.updateOtherDetails()
                self.tableView.reloadData()
            }
        }
    }

    private func updateOtherDetails() {
        self.title = vm?.meshName
        self.vm?.getUpdateInfo()
    }

    private func addMoreMenu() {
        let rename = UIAction(title: "Rename Mesh",
                              image: UIImage(systemName: "pencil")) {_ in
            self.tappedRename()
        }

        let menu = UIMenu(title: "Mesh Options",
                          options: .displayInline,
                          children: [rename])

        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                         primaryAction: nil, menu: menu)

        self.navigationItem.rightBarButtonItem = moreButton
    }

    private func tappedRename() {
        if let name = vm?.meshName {
            let message = "Names should be under 32 characters, begin with an alphabetic character. Only letters, numbers, _ and - are allowed.".localized()

            let dialogView = RenameDialogView(title: "Rename Mesh".localized(),
                                              message: message,
                                                  textFieldText: name) { okTapped, newName in
                if okTapped && name != newName {
                    self.sendNameUpdate(newName: newName)
                }

                self.renameDialog?.fadeOut {
                    self.renameDialog?.removeFromSuperview()
                }
            }

            self.renameDialog = SwiftUIUIView<RenameDialogView>(view: dialogView,
                                                                    requireSelfSizing: true).make()
            renameDialog?.alpha = 0
            if let window = UIApplication.shared.windows.filter ({$0.isKeyWindow}).first {
                self.renameDialog!.frame = window.frame
                window.addSubview(renameDialog!)
                renameDialog?.fadeIn {}
            }
        }
    }

    private func sendNameUpdate(newName: String) {

        // Check the name validity
        if let message = NameValidation.meshNameHasErrors(name: newName) {
            showInfoWarning(message: "Could not rename: ".localized() + message)
            return
        }

        Task {
            if let error = await vm?.updateMeshName(newName: newName) {
                await MainActor.run { showAlert(with: "Error".localized(), message: error) }
            }
            else {
                await MainActor.run {
                    self.title = vm?.meshName ?? "VeeaHubs".localized()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func registerForAppForgroundingNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func willEnterForground() {
        guard let meshDetailViewModel = vm else {
            self.navigationController?.popViewController(animated: false)
            return
        }
        
        self.progressViewContainer.isHidden = true
        self.stackView.layoutIfNeeded()
        meshDetailViewModel.getUpdateInfo()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstProgressRequestAfterViewAppear = true
        recordScreenAppear()
        
        guard let meshDetailViewModel = vm else {
            self.navigationController?.popViewController(animated: false)
            
            return
        }

        self.addNetworkObserver()
        disconnectFromHubWiFi()
        self.vm?.restartTimer()
        self.tabBarController?.tabBar.isHidden = true
        
        self.title = meshDetailViewModel.meshName
        meshDetailViewModel.viewIsVisible = true
        meshDetailViewModel.getUpdateInfo()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            meshDetailViewModel.getUpdateInfo()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.vm?.viewIsVisible = false
    }
    
    fileprivate func disconnectFromHubWiFi() {
        HubApWifiConnectionManager.shared.currentlyConnectedHub = nil
        HubDataModel.shared.connectedVeeaHub = nil
        WiFi.disconnectFromAllNetworks()
        
        ApiFactory.api.deleteCurrentAuthToken()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.vm?.networkAvailable.observer = nil
    }
    
    override func reachabilityUpdated(status: VKReachabilityManagerStatus) {
        self.vm?.networkAvailable.data = status
    }
    
    func configureHealthPill() {
        healthBillHeightConstraint.constant = 81.0
        guard let health = vm?.meshHealth else { return }
        if vm?.neededRebootCountVar != 0 {
            healthBillHeightConstraint.constant = 111.0
            healthPill.setDetailsWithRestartStatus(pillColor: health.color, titleStr: health.stateTitle, subTitleStr: health.meshDescription, restartStatusCount: vm?.neededRebootCountVar ?? 0)
        }
        else{
            healthPill.setState(state: health)
        }
    }
    
    func configureHealthPillWithRestart(restartHubsCount:Int) {
        guard let health = vm?.meshHealth else { return }
        healthBillHeightConstraint.constant = 111.0
        healthPill.setDetailsWithRestartStatus(pillColor: health.color, titleStr: health.stateTitle, subTitleStr: health.meshDescription, restartStatusCount: restartHubsCount)
    }
    
    func addObservers() {
        guard let meshDetailViewModel = vm else { return }
        
        meshDetailViewModel.isBluetoothEnabled.observer = { [weak self] _ in
            self?.configureHealthPill()
        }
    }
    
    func addNetworkObserver() {
        guard let meshDetailViewModel = vm else {
            self.navigationController?.popViewController(animated: false)
            return
        }
        
        meshDetailViewModel.networkAvailable.observer = { [weak self] status in
            self?.configureHealthPill()
            
            if let tbvc = self?.tabBarController as? MainTabViewController {
                
                tbvc.setEnableTabs(enabled: status == .connected)
            }
            
            if let nav = self?.navigationItem {
                nav.hidesBackButton = status != .connected
            }
        }
    }
    
    deinit {
        vm?.cleanUp()
        vm = nil
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource
extension MeshDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm?.getNumberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vm == nil { return 0 }
        return vm!.getNumberOfRows(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeTableViewCell", for: indexPath)
        if let cellModel = vm?.getViewModel(at: indexPath) {
            if let cell = cell as? NodeTableViewCell {
                cell.setupcell(cellModel: cellModel, vm: vm)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vm?.titleForHeader(in: section)
    }
}

// MARK: - UITableViewDelegate
extension MeshDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard vm != nil else { return }
        
        self.tableView.isUserInteractionEnabled = false
        tableView.deselectRow(at: indexPath, animated: true)
        
        connectToItemAt(indexPath: indexPath)
    }

    private func unenrollItemAt(indexPath: IndexPath) {
        guard let model = vm,
              let connectionInfo = model.getConnectionInfo(indexPath: indexPath) else { return }

        let r = HubRemover.canHubBeRemoved(connectionInfo: connectionInfo)
        if !r.0 {
            showInfoAlert(title: "Cannot remove VeeaHub".localized(),
                          message: r.1 ?? "Please disconnect from the hub, reconnect and try to remove again".localized())

            return
        }

        let alert = UIAlertController.init(title: "Remove VeeaHub".localized(),
                                           message: "Are you sure you want to remove this VeeaHub?".localized(),
                                           preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "REMOVE".localized(), style: .destructive, handler: { [weak self] (action) in
            
            self?.doUnEnrollNode(indexPath: indexPath)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func doUnEnrollNode(indexPath: IndexPath) {
        guard let model = vm,
              let connectionInfo = model.getConnectionInfo(indexPath: indexPath) else { return }

        UnEnrollmentService.unEnroll(node: connectionInfo.selectedMeshNode) { success in
            if success.0 {
                self.showSuccessWarning(message: "Unenrollment Request sent.\nRefresh mesh info")
                self.navigationController?.popViewController(animated: true)
                return
            }

            if let errorMetaData = success.2 {
                if (errorMetaData.title == "" &&  errorMetaData.suggestions?.count == 0) {
                    self.showErrorInfoMessage(message: success.1 ?? "Unknown Error" )
                }
                else {
                    self.showErrorHandlingAlert(title: errorMetaData.title ?? "", message: errorMetaData.message ?? "", suggestions: errorMetaData.suggestions ?? [])
                }
            }
            else {
                self.showErrorInfoMessage(message: success.1 ?? "Unknown Error" )
            }
            
        }
    }

    private func connectToItemAt(indexPath: IndexPath,
                                 viewUserDashboard: Bool = false) {
        guard let model = vm else { return }
        let connectionInfoNeededForStatus = model.getConnectionInfo(indexPath: indexPath)
        vm?.connectionInfo = connectionInfoNeededForStatus

        guard let showPreparingScreen = model.showEnrollingInfoIfNeeded(at: indexPath) else {
            let connectionInfo = model.getConnectionInfo(indexPath: indexPath)
            if !(connectionInfo?.isAvailableForConnection ?? false) {
                self.tableView.isUserInteractionEnabled = true
                
                if let connectionInfo = connectionInfo {
                    showFailDialog(connection: connectionInfo)
                }
                else {
                    showAlert(with: "Error".localized(), message: "Could get a connection route. Please refresh and try again".localized(), actions: nil)
                }
                
                return
            }
            
            if let reason = connectionInfo?.availableButNotAllowedReason {
                showInfoMessage(message: reason)
                
                // For testing the fail dialog
                if Target.currentTarget == .QA {
                    showFailDialog(connection: connectionInfo!)
                }
                
                self.tableView.isUserInteractionEnabled = true
                return
            }
            
            self.makeConnection(connectionInfo: connectionInfo,
                                pushToHomeDashboard: viewUserDashboard)
            self.tableView.isUserInteractionEnabled = true
            
            return
        }
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .allowAnimatedContent, animations: { [self] in
            if showPreparingScreen.pushView {
                self.show(showPreparingScreen.vc, sender: self)
            } else {
                showPreparingScreen.vc.modalPresentationStyle = .overFullScreen
                self.present(showPreparingScreen.vc, animated: true, completion: nil)
            }
            
        }, completion: { (finished: Bool) in
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.isUserInteractionEnabled = true
        })
    }
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        if Target.currentTarget != .QA {
            return nil
        }

        let homeUserDashboard = UIAction(title: "Home User Dashboard", image: UIImage(named: "iconHome")) { action in
            self.connectToItemAt(indexPath: indexPath,
                                 viewUserDashboard: true)
        }
        let unenroll = UIAction(title: "Unenroll node", image: UIImage(systemName: "trash")) { action in
            self.unenrollItemAt(indexPath: indexPath)
        }
        return nil
//        return UIContextMenuConfiguration(identifier: nil,
//                                          previewProvider: nil) { _ in
//            UIMenu(title: "Tester Options...", children: [homeUserDashboard, unenroll])
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Connection
extension MeshDetailViewController {
    private func makeConnection(connectionInfo: ConnectionInfo?,
                                pushToHomeDashboard: Bool = false) {
        HubDataModel.shared.snapShotInUse = false
        guard let hub = connectionInfo?.veeaHub else {
            return
        }
        
        if connectionProgressAlert == nil {
            connectionProgressAlert = ConnectionProgressAlert.init(frame: self.view.frame)
        }
        
        connectionProgressAlert?.connectToHub(hub: hub, completion: { (success, message) in
            if success {
                if !HubDataModel.shared.isDataSetComplete {
                    if let connectionInfo = connectionInfo {
                        self.makeConnection(connectionInfo: connectionInfo)
                        return
                    }
                    
                    showAlert(with: "Error".localized(), message: "Error getting configuration details.\nPlease wait a moment and try again.".localized(), actions: nil)
                    return
                }
                
                if pushToHomeDashboard {
                    if let connectionInfo = connectionInfo {
                        self.pushToTheHomeDash(connection: connectionInfo)
                    }
                    else {
                        assertionFailure("No connection info")
                    }
                }
                else {
                    self.pushToTheDash(connection: connectionInfo)
                }
            }
            else {
                self.disconnectFromHubWiFi()
                self.showFailDialog(connection: connectionInfo!)
                self.removeConnectionProgressAlert()
            }
        })
        
        connectionProgressAlert!.alpha = 0.0
        UIWindow.sceneWindow?.addSubview(connectionProgressAlert!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.connectionProgressAlert!.alpha = 1.0
        })
    }
    
    private func showFailDialog(connection: ConnectionInfo) {
        let alert = CouldNotConnectAlert.init(hostViewController: self, connectionInfo: connection)
        
        alert.showAlert { (connection) in
            if connection.isAvailableForConnection && self.routeIsPermitted(connection: connection) {
                self.makeConnection(connectionInfo: connection)
            }
            else {
                if let connectionInfo = self.vm?.refreshConnectionInfo(connectionInfo: connection) {
                    self.showFailDialog(connection: connectionInfo)
                }
            }
        }
    }

    private func routeIsPermitted(connection: ConnectionInfo) -> Bool {
        if !BackEndEnvironment.internalBuild { return true }

        let testerSelectedRoutes = TesterDefinedConnectionRoutes.selectedRoutes
        var route: TesterDefinedConnectionRoutes.ConnectionRoute?
        switch connection.veeaHub.connectionRoute {
        case .CURRENT_GATEWAY:
            route = .ap
        case .DNS:
            route = .lan
        case .MAS_API:
            route = .hubAvailableOnMas
        }

        guard let route else { return false }

        return testerSelectedRoutes.contains(route)
    }
    
    private func pushToTheHomeDash(connection: ConnectionInfo) {
        let vc = HomeDashboardViewController.new(meshes: [connection.selectedMesh], for: vm!.groupId)
        self.navigationController?.pushViewController(vc, animated: true)
        self.tabBarController?.tabBar.isHidden = true
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
    
    private func removeConnectionProgressAlert() {
        connectionProgressAlert?.tearDown()
        connectionProgressAlert = nil
    }
}

// MARK: - Updates Available
extension MeshDetailViewController {
    func showUpdatePill(numberOfUpdates: Int) {
        self.updatePillContrainerView.isHidden = true
        return
        
        // 2 December 2021 15:52:49 = Hiding this for the moment. Most important to show the progress
        
        /*
         if numberOfUpdates == 0 {
         self.updatePillContrainerView.isHidden = true
         return
         }
         
         updatePill.numberOfUpdates = numberOfUpdates
         
         UIView.animate(withDuration: 0.3) {
         self.updatePillContrainerView.isHidden = false
         self.stackView.layoutIfNeeded()
         }
         
         */
    }
    
    private func updateTapped() {
        guard let model = vm,
              let menSerial = model.menUnitSerial else {
            showInfoAlert(title: "Error", message: "No MEN on in this mesh")
            return
        }
        
        let vc = UIStoryboard(name: "MeshDetail", bundle: nil).instantiateViewController(withIdentifier: "MeshUpdateViewController") as! MeshUpdateViewController
        vc.configure(groupId: model.groupId,
                     meshUUID: model.meshUUID,
                     menSerial: menSerial,
                     packagesToUpdate: model.updatePackages!)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showUpdateProgress(status: MeshUpdateStatus?) {
        guard let status = status else {
            progressViewContainer.isHidden = true
            return
        }
        
        // The backend keeps reporting a completed progress for a short time after completion
        // If we come to this page and find that to be the case, we do not want to show the progress bar
        if firstProgressRequestAfterViewAppear && status.progressComplete {
            return
        }
        
        firstProgressRequestAfterViewAppear = false
        
        // Show
        if let lastStep = status.lastStep {
            if lastStep.progress == 100.0 && lastStep.isLastStep {
                hideUpdateProgress()
                return
            }
        }
        
        showUpdateProgress()
        
        // Update the progress view
        progressView.updateProgress(status: status)
    }
}

// MARK: - Update Progress
extension MeshDetailViewController {
    func showUpdateProgress() {
        UIView.animate(withDuration: 0.3) {
            self.progressViewContainer.isHidden = false
            self.stackView.layoutIfNeeded()
        }
    }
    
    func hideUpdateProgress() {
        UIView.animate(withDuration: 0.3) {
            self.progressViewContainer.isHidden = true
            self.stackView.layoutIfNeeded()
        }
    }
}

extension MeshDetailViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        vm?.searchTerm = searchController.searchBar.text?.lowercased() ?? ""
        tableView.reloadData()
    }
}

extension MeshDetailViewController: HubInteractionFlowControllerProtocol {}

extension MeshDetailViewController: MeshUpdateProgressViewFinishedProtocol {
    func finished() {
        // Tell the data model we have finished and to stop returning polling results: VHM-1287
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hideUpdateProgress()
        }
    }
}
