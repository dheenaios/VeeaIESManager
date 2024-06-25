//
//  MeshSelectionViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 29/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class MeshSelectionViewController: UIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .meshes_screen

    private let TAG = "MeshSelectionViewController"
    
    var flowController: HubInteractionFlowController?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addVHButton: UIButton!
    private var searchBar: UISearchBar?

    private var noDevicesView: NoDevicesView?
    private var datasource = MeshesDataSource()
    private var vm: MeshSelectionViewModel!
    private var errorView: VUIErrorView?

    private var activityBackingView: UIView?
    private var activity: UIActivityIndicatorView?

    private var switchGroupButton: UIBarButtonItem?

    private var groupSwitcher: UIViewController?
    
    private var meshIdFromNotifcation:String?

    // The item that should host the search bar.
    // This view controller may be shown within a container.
    // If it is, then we want to show the search bar in the parents container.
    private var parentsNavItem: UINavigationItem?
    
    /// Create an instance of the View Controller
    public static func newVc(groupService: UserGroupService,
                             groupDetails: GroupDetailsModel,
                             parentsNavigationItem: UINavigationItem?) -> MeshSelectionViewController {
        let meshesViewController = UIStoryboard(name: "GroupMeshSelection", bundle: nil).instantiateViewController(withIdentifier: "MeshSelectionViewController") as! MeshSelectionViewController

        meshesViewController.searchBar = meshesViewController.addSearchBar(placeHolderText: "Search".localized(),
                                      searchResultsUpdater: meshesViewController,
                                      hostNavigationItem: parentsNavigationItem)
        meshesViewController.searchBar?.isHidden = true

        meshesViewController.vm = MeshSelectionViewModel(groupService: groupService,
                                                         selectedGroup: groupDetails)
        meshesViewController.parentsNavItem = parentsNavigationItem
        
        return meshesViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVHButton.accessibility(config: AccessibilityConfigurations.buttonAddHub)
        parentsNavItem?.title = vm.selectedGroup.groupDisplayName
        self.tableView.dataSource = datasource

        addSwitchGroupButton()
        setUpRefreshControl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MeshSelectionViewController.refreshMeshes), name: Notification.Name.updateMeshes, object: nil)

        self.bindViewModel()
        //self.refreshGroupData()
        
        hideAddHubButton(hide: true, animated: false)
        self.searchBar?.isHidden = true
        setTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(MeshSelectionViewController.logoutAction), name: NSNotification.Name.logoutNotification, object: nil)
    }

    @objc func logoutAction() {
        GroupFavoritesController.shared.clearLocalFavorites()
        groupSwitcher = nil
    }

    deinit {
      NotificationCenter.default.removeObserver(self)
    }

    private func addSwitchGroupButton() {
        let groups = vm.userGroupsService.groupModels
        let soloGroupHasChildren = (groups.count == 1 || groups.first?.counts.children ?? 0 > 0)
        if groups.count > 1 || soloGroupHasChildren {
            self.switchGroupButton = UIBarButtonItem(title: "Switch Group".localized(),
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(switchGroupButtonTapped))
            parentsNavItem?.leftBarButtonItem = switchGroupButton
            self.switchGroupButton?.isEnabled = false // Do not enable until the info has loaded.
        }
    }

    @objc
    func switchGroupButtonTapped() {
        if groupSwitcher == nil {
            groupSwitcher = GroupBrowserNavigationView.newViewController(selectedGroupId: vm.selectedGroup.groupId,
                                                                         topLevelGroups: vm.userGroupsService,
                                                                         delegate: self, selectedSegment: 0)
        }
        
        present(groupSwitcher!, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        // Update the navbar globally and locally
        updateNavBarWithDefaultColors(largeTitleFontSize: 20.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.tabBarController?.tabBar.isHidden = false
        self.loadMeshesData()
        self.recordScreenAppear()
        GroupFavoritesController.shared.updateIfNeeded() // Add this here to preload favorites
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        vm.hasViewVanishedSinceLastUpdate = true
    }
    
    private func setUpRefreshControl() {
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.tintColor = .darkGray
        self.tableView.refreshControl?.addTarget(self, action: #selector(MeshSelectionViewController.refreshMeshes), for: .valueChanged)
    }
    
    func loadMeshesData() {
        guard let lastDataLoad = vm.lastDataLoad else {
            loadData()
            return
        }
        
        if lastDataLoad.inLast(seconds: 20) && vm.hasViewVanishedSinceLastUpdate {
            vm.hasViewVanishedSinceLastUpdate = false
            return
        }
        loadData()
    }
    
    private func loadData() {
        if self.vm.selectedGroup.hasMeshes || !self.vm.selectedGroup.hasMultipleGroups {
            self.vm.loadGroupConfigForCurrentGroup()
        }else{
            self.tableView.alpha = 0
            self.loadTableData()
            self.showNoDevicesView()
        }
    }
    
    func bindViewModel() {
        vm.isLoading.observer = { [weak self] status in
            if status {
                self?.tableView.disableView(disabled: true)
                self?.switchGroupButton?.isEnabled = false
                self?.showLoadingControl()
            } else {
                self?.hideLoadingControl()
                self?.switchGroupButton?.isEnabled = true
                self?.tableView.disableView(disabled: false)
            }
        }
        
        vm.showTableContent.observer = { [weak self] show in
            if show {
                self?.tableView.alpha = 1
                self?.loadTableData()
                self?.switchGroupButton?.isEnabled = true
            } else {
                self?.tableView.alpha = 0
                self?.switchGroupButton?.isEnabled = false
            }
        }
        
        vm.showNodeviceView.observer = { [weak self] show in
            if show {
                self?.showNoDevicesView()
            } else {
                self?.removeNoDeviceView()
            }

            self?.switchGroupButton?.isEnabled = true
        }
        
        vm.errorOccured.observer = { [weak self] errorMessage in
            self?.removeError()
            if !errorMessage.isEmpty {
                self?.showError(with: "Oops!".localized(), message: errorMessage)
            } else {
                self?.loadTableData()
            }
        }
        vm.showMeshDetailsForNotification.observer = { [weak self] show in
            if show {
                self?.navigateToMeshDetailsFromNotificationLaunchAfterLoadingGroupInfo()
            }
        }
    }
//    func refreshGroupData(){
//        self.vm.groupVM.loadGroups {
//        } error: { errMsg in
//        }
//    }
    
    func loadTableData() {
        parentsNavItem?.title = vm.selectedGroup.groupDisplayName
        self.datasource.meshViewModels = self.vm.getViewMeshModels()
        self.datasource.hasMultipleGroups = self.vm.selectedGroup.hasMultipleGroups
        self.tableView.reloadData()
        flowController?.currentViewController = self
    }
    
    func showError(with title: String, message: String) {
        errorView = VUIErrorView(frame: self.view.bounds, title: title, message: message)
        errorView?.centerInView(superView: self.view, mode: .horizontal)
        errorView?.center.y = (self.view.bounds.height - self.tabBarHeight)/2
        errorView?.callback = { [weak self] in
            self?.vm.loadGroupConfigForCurrentGroup()
            self?.removeError()
        }
        self.view.addSubview(errorView!)
    }
    
    func removeError() {
        self.errorView?.removeFromSuperview()
        self.errorView = nil
    }
    
    func showNoDevicesView() {
        hideLoadingControl()
        
        if noDevicesView != nil { return }
        self.addVHButton?.isHidden = true
        noDevicesView = NoDevicesView()
        noDevicesView?.centerInView(superView: self.view, mode: .horizontal)
        noDevicesView?.center.y = (self.view.bounds.height)/2
        noDevicesView?.openDeviceCallback = { [weak self] in
            self?.addNewDevice(self)
        }
        self.view.addSubview(noDevicesView!)
    }
    
    func removeNoDeviceView() {
        self.addVHButton?.isHidden = false
        self.noDevicesView?.removeFromSuperview()
        self.noDevicesView = nil
    }
    
    func showLoadingControl() {
        hideAddHubButton(hide: true, animated: true)
        self.searchBar?.isHidden = true
        tableView.isUserInteractionEnabled = false
        if self.activity != nil {
            return
        }
        
        if errorView != nil { return }
        
        showActivitySpinner(show: true)
    }

    func hideLoadingControl() {
        hideAddHubButton(hide: false, animated: true)
        self.searchBar?.isHidden = false
        tableView.isUserInteractionEnabled = true
        showActivitySpinner(show: false)
        self.tableView.refreshControl?.endRefreshing()
    }

    private func showActivitySpinner(show: Bool) {
        if show {
            self.activity = UIActivityIndicatorView(style: .large)
            self.activityBackingView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            self.activityBackingView?.backgroundColor = .systemGroupedBackground
            self.activityBackingView?.alpha = 0.4
            self.activityBackingView?.layer.cornerRadius = 10
            self.activityBackingView?.layer.shadowColor = UIColor.black.cgColor
            self.activityBackingView?.layer.shadowOpacity = 0.4
            self.activityBackingView?.layer.shadowOffset = .zero
            self.activityBackingView?.layer.shadowRadius = 10
            self.activityBackingView?.alpha = 1.0

            self.activity?.color = .darkGray

            self.activityBackingView?.center.y = UIScreen.main.bounds.height / 2
            self.activityBackingView?.center.x = UIScreen.main.bounds.width / 2

            self.view.addSubview(self.activityBackingView!)
            activityBackingView?.addSubview(activity!)
            self.activity?.centerInView(superView: activityBackingView!, mode: .horizontal)
            self.activity?.centerInView(superView: activityBackingView!, mode: .vertical)

            self.activity?.startAnimating()

            return
        }

        // Remove
        self.activity?.stopAnimating()
        self.activity?.removeFromSuperview()
        self.activityBackingView?.removeFromSuperview()
        self.activity = nil
    }
    
    @objc func refreshMeshes() {
        if noDevicesView != nil {
            noDevicesView?.removeFromSuperview()
            noDevicesView = nil
        }
        self.showLoadingControl()
        self.refreshView()
    }
    
    @objc func refreshView() {
        self.vm.loadGroupConfigForCurrentGroup()
    }
    
    func hideAddHubButton(hide: Bool, animated: Bool) {
        let alpha = hide ? 0.0 : 1.0
        if !animated {
            addVHButton.alpha = alpha
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.addVHButton.alpha = alpha
        }
    }
    
    // MARK: - Navigation
    @IBAction func addNewDevice(_ sender: Any?) {
        let enrollmentFlowCoordinator = EnrollmentFlowCoordinator()
        enrollmentFlowCoordinator.meshes = vm.getAvailableMeshes()
        enrollmentFlowCoordinator.groupDetailsVM = self.vm.selectedGroup
        let addDeviceVC = UINavigationController(rootViewController: enrollmentFlowCoordinator)
        addDeviceVC.modalPresentationStyle = .overFullScreen
        self.present(addDeviceVC, animated: true, completion: nil)
    }
    
    func navigateToMeshDetailsFromNotificationLaunchAfterLoadingGroupInfo() {
        var log = "Attempting to find mesh \(String(describing: self.meshIdFromNotifcation))."

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            for (index, mesh) in self.vm.availableMeshes.enumerated() {
                if self.meshIdFromNotifcation == mesh.id {
                    log.append("\nFound mesh. Pushing to mesh details.")
                    Logger.log(tag: self.TAG, message: log)
                    let indexPath = IndexPath(row: index, section: 0)
                    self.push(indexPath: indexPath)
                    self.flowController?.clearNotification()
                    return
                }
            }
            log.append("\nMesh NOT found.")
            Logger.log(tag: self.TAG, message: log)
        }
    }
}

// MARK: - UITableViewDelegate
extension MeshSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let meshes = vm.getAvailableMeshes()
        if meshes[indexPath.row].name == nil {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.async {
            self.show(self.vm.viewToShow(for: indexPath), sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 90
    }
    
}

extension MeshSelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        vm.searchTerm = searchController.searchBar.text?.lowercased() ?? ""
        loadTableData()
    }
}

extension MeshSelectionViewController: HubInteractionFlowControllerProtocol {
    func handleNotificationWithDetails(groupId: String, meshId: String) {        
        if self.vm.selectedGroup.groupId != groupId {
            if let group = vm.userGroupsService.groupModels.first(where: { $0.id == groupId }) {
                GroupModel.selectedModel = group
            }
        }
        self.meshIdFromNotifcation = meshId
        self.vm.loadGroupConfigForHandlingPush(groupId: groupId)
        self.loadTableData()
    }
    
    private func push(indexPath: IndexPath) {
        DispatchQueue.main.async {
            let vc = self.vm.viewToShow(for: indexPath)
            if let vc = vc as? HubInteractionFlowControllerProtocol {
                vc.flowController = self.flowController
            }
            
            self.show(vc, sender: self)
        }
    }
}

extension MeshSelectionViewController: GroupBrowserSelectionDelegate {
    func didShowErrorHandlingAlert(data:ErrorHandlingData?) {
        self.showErrorHandlingAlert(title: data?.title ?? "", message: data?.message ?? "", suggestions: data?.suggestions ?? [])
    }
    
    func selectionMade(group: GroupModel) {
        self.vm.loadGroupConfigForCurrentGroup(id: group.id)
        self.parentsNavItem?.title = self.vm.selectedGroup.groupDisplayName
    }
}
