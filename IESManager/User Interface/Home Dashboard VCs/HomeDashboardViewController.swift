//
//  HomeDashboardViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 04/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class HomeDashboardViewController: HomeUserBaseViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .home_dashboard_screen

    @IBOutlet weak var header: HomeDashboardHeader!
    
    @IBOutlet weak var collectionView: UICollectionView!
    let refreshControl = UIRefreshControl()
    
    private var vm: HomeDashboardViewModel!
    let notificationRequest = PushNotificationRequest()
    
    static func new(meshes: [VHMesh], for groupId: String) -> HomeDashboardViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserDashboard.rawValue, bundle: nil).instantiateInitialViewController() as! HomeDashboardViewController
        let vm = HomeDashboardViewModel(meshes: meshes,
                                        for: groupId)
        vc.vm = vm
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = InterfaceManager.shared.cm.background2.colorForAppearance
        hideNavBar(true, animated: false)

        header.delegate = self
        updateHeader()
        
        vm.addAsObserver { type in
            self.updateHeader()
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
        
        notificationRequest.requestNotificationPermissions {
            PushNotificationRequest.sendTokenToBackendIfNeeded()
        }

        refreshControl.addTarget(self, action: #selector(load), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.stopTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.startTimer()
        recordScreenAppear()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showTestersMenu()
        }
    }
    
    override func setTheme() {
        super.setTheme()
        
        view.backgroundColor = InterfaceManager.shared.cm.background2.colorForAppearance
        collectionView.backgroundColor = InterfaceManager.shared.cm.background2.colorForAppearance
    }

    @objc private func load() {
        vm.reloadMen()
    }
    
    private func updateHeader() {
        header.setUp(config: vm.headerConfig)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNavBar(true, animated: false)

        if !vm.menDataLoaded {
            vm.reloadMen()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension HomeDashboardViewController: HomeDashboardHeaderDelegate {
    func cellularLearnMoreTapped() {
    }

    func errorTapped() {
    }
    
    func preparingTapped() {
        guard let mesh = vm.mesh,
              let model = vm.meshDetailViewModel else { return }
        
        let vc = HomePreparingSummaryViewController.new(mesh: mesh, meshDetailViewModel: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeDashboardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = vm.dashboardItems[indexPath.row]
        
        if model.requiresHubData && !vm.menDataLoaded { return }
        if model.faded { return }
        
        guard let mesh = vm.mesh,
              let meshDetailsVm = vm.meshDetailViewModel else { return }
        
        if let vc = HomeDashboardDestinationManager.viewControllerFor(dashboardItem: model,
                                                                      mesh: mesh,
                                                                      meshDetailViewModel: meshDetailsVm) {
            hideNavBar(false, animated: false)
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assertionFailure("Unknown View Controller")
        }
    }
}

extension HomeDashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DashboardCell
        let model = vm.dashboardItems[indexPath.row]
        cell.configure(config: model)
        
        cell.contentView.alpha = 1.0
        if model.faded {
            cell.contentView.alpha = 0.3
        }
        else if model.requiresHubData {
            if !vm.menIsConnectedToMas {
                cell.contentView.alpha = 0.3
            }
            else {
                cell.contentView.alpha = vm.menDataLoaded ? 1.0 : 0.3
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.dashboardItems.count
    }
}

extension HomeDashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 30) / 2
        return CGSize(width: size, height: 150)
    }
}

protocol MeshStateDelegate: AnyObject {
    func meshStateUpdated()
}

class DashboardCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(config: HomeDashboardItem) {
        titleLabel.text = config.title
        imageView.image = config.image
        
        titleLabel.font = FontManager.light(size: 17)
    }
}
