//
//  EnrollmentStatusViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/29/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class EnrollmentStatusViewController: VUIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .installing_veeahub_screen

    var scrollView: UIScrollView!
    var unenrollButton: VUIFlatButton!
    var activityIndicator: UIActivityIndicatorView!
    var preparingLabel: UILabel!
    var infoLabel: UILabel!
    var progressView: VUIProgressView!
    var statusView: EnrollStatusView!
    var errorView: VUIErrorView?
    var statusIcon: UIImageView?
    var statusImage: UIImage?
        
    private var device: VHMeshNode!
    private var mesh: VHMesh!
    public var connectionInfo: ConnectionInfo?

    
    private var refreshTimer: Timer?
    
    var enrollStatus: EnrollStatusViewModel! {
        didSet {
            DispatchQueue.main.async {
                self.updateStatus()
            }
        }
    }
    
    convenience init(for device: VHMeshNode, mesh: VHMesh, connectionInfo: ConnectionInfo) {
        self.init()
        self.device = device
        self.mesh = mesh
        self.connectionInfo = connectionInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Header View with IES details
        let deviceType = String(describing: VeeaHubHardwareModel(serial: device.id) )
        let headerView = HeaderImageViewWithTitle(image: UIImage(named: "default-device-icon")!, title: device.name, detailText: "\(deviceType) • \(String(describing: device.id!))")
        headerView.frame.origin.y = self.navbarMaxY
        headerView.backgroundColor = UIColor(named: "NavigationBarTint")
        
        let gestureRecogniser = UILongPressGestureRecognizer.init(target: self, action: #selector(copyHubDetailsToDashboard))
        headerView.addGestureRecognizer(gestureRecogniser)
        
        self.view.addSubview(headerView)
        
        let frame = CGRect.init(x: self.view.bounds.origin.x,
                                y: headerView.bottomEdge,
                                width: self.view.bounds.width,
                                height: self.view.bounds.height - headerView.bottomEdge)
        
        scrollView = UIScrollView(frame: frame)
        scrollVerticalStyle(scrollView)
        self.view.addSubview(scrollView)
        scrollView.addOffset(UIConstants.Margin.side * 2)
        
        let buttonHeight: CGFloat = 40.0

        let window = UIWindow.sceneWindow
        var bottomPadding = window?.safeAreaInsets.bottom ?? 0
        if bottomPadding != 0 {
            bottomPadding += 30 // Bigger tab bars on X series phones
        }
        
        let bottomSpace = 44 + bottomPadding
        
        unenrollButton = VUIFlatButton(frame: CGRect(x: UIConstants.Margin.side,
                                                     y: self.view.frame.height - bottomSpace,
                                                     width: UIConstants.contentWidth,
                                                     height: buttonHeight),
                                       type: VUIFlatButtonType.red, title: "Remove VeeaHub from Account".localized())
        unenrollButton.addTarget(self, action: #selector(unenrollTapped),
                                 for: .touchUpInside)
        unenrollButton.isHidden = false
        
        self.view.addSubview(unenrollButton)
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .darkGray
        activityIndicator.centerInView(superView: self.scrollView, mode: .horizontal)
        scrollView.push(activityIndicator)
        activityIndicator.startAnimating()
        scrollView.addOffset(UIConstants.Margin.side)
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true, block: { (timer) in
            self.loadData()
        })
        
        refreshTimer?.fire()
        self.addInfoButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordScreenAppear()
    }


    @objc private func showInfoAlertMessage(){
        let alert = UIAlertController(title: "Info".localized(),
                                      message: "We appreciate your patience while your unit is downloading the operating system and the required network software. This process typically takes about 20-40 minutes depending on the speed of your internet connection.".localized(),
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default) { _ in
        })
        
        self.present(alert, animated: true)
    }
    
    private func addInfoButton(){
        
        let infoBtn = UIButton(type: .infoLight)

        infoBtn.addTarget(self, action: #selector(showInfoAlertMessage), for: .touchUpInside)

        let infoBarButtonItem = UIBarButtonItem(customView: infoBtn)

        self.navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    @objc private func copyHubDetailsToDashboard() {
        if let id = device.id {
            let alert = UIAlertController(title: "Copy device details".localized(),
                                          message: "\("Copy".localized()): \(id)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "\("Cancel".localized())", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction.init(title: "\("OK".localized())", style: .default, handler: { (action) in
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = id
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        refreshTimer?.invalidate()
    }
    
    func renderView(status: EnrollStatusViewModel) {
        // Preparing text label
        preparingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIConstants.contentWidth, height: 0))
        preparingLabel.text = String(format: "\("Preparing your VeeaHub".localized()) (%g%%)", status.percentage)
        smallTitleStyle(preparingLabel)
        centerStyle(preparingLabel)
        preparingLabel.centerInView(superView: scrollView, mode: .horizontal)
        scrollView.push(preparingLabel)
        scrollView.addOffset(5)
        
        // Info label
        infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.8, height: 0))
        infoLabel.text = "This might take a few minutes depending on the speed of your Internet connection. Tap on the \"i\" icon for more information".localized()
        multilineCenterLabelStyle(infoLabel)
        infoLabel.centerInView(superView: scrollView, mode: .horizontal)
        scrollView.push(infoLabel)
        scrollView.addOffset(UIConstants.Margin.top)
        
        progressView = VUIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.6, height: 10))
        progressView.centerInView(superView: scrollView, mode: .horizontal)
        progressView.progress = status.percentage
        scrollView.push(progressView)
        scrollView.addOffset(UIConstants.Margin.side * 2)
        
        statusView = EnrollStatusView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.78, height: 0), items: status.subtasks)
        statusView.centerInView(superView: self.scrollView, mode: .horizontal)
        self.scrollView.push(statusView)
        scrollView.addOffset(UIConstants.Margin.side * 2)
        
        let spacerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 40.0))
        spacerView.centerInView(superView: self.scrollView, mode: .horizontal)
        self.scrollView.push(spacerView)
        
        if traitCollection.userInterfaceStyle == .dark {
            preparingLabel.textColor = .white
            infoLabel.textColor = .white
        }
    }
    
    func updateStatus() {
        self.progressView.progress = enrollStatus.percentage
        statusView.update(with: enrollStatus.subtasks)
        
        if enrollStatus.didFail {
            unenrollButton.isHidden = false
        }
        
        if enrollStatus.percentage == -1 {
            self.showPreperationFailed()
        } else {
            self.preparingLabel.text = String(format: "\("Preparing your VeeaHub".localized()) (%g%%)", enrollStatus.percentage)
        }
        
        for task in enrollStatus.subtasks {
            if task.status == .failed {
                self.showPreperationFailed()
            }
        }
        
        if enrollStatus.percentage == 100 {
            self.preparingLabel.text = "First set up complete".localized()
            self.infoLabel.text = "Your VeeaHub is ready for use.".localized()
            self.statusImage = UIImage(named: "checkmark-icon")
            self.showStatusIcon()
            self.stopActivity()
            
            // Go back to
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func unenrollTapped() {
        
        let r = HubRemover.canHubBeRemoved(connectionInfo: self.connectionInfo)
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
            self?.doUnEnroll()
        }))

        present(alert, animated: true, completion: nil)

    }
    
    func doUnEnroll() {
        self.unEnrollHub(node: device)
    }
    
    func showPreperationFailed() {
        self.statusImage = UIImage(named: "icon-error")?.withRenderingMode(.alwaysTemplate).tintWithColor(.vRed)
        self.preparingLabel.text = "Failed to add VeeaHub".localized()
        self.infoLabel.removeFromSuperview()
        self.progressView.removeFromSuperview()
        self.statusView.frame = self.statusView.frame.offsetBy(dx: 0, dy: -self.infoLabel.frame.height)
        self.showStatusIcon()
        refreshTimer?.invalidate()
        self.stopActivity()
    }
    
    func stopActivity() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        RefreshStatusTimer.timer?.invalidate()
    }
    
    func showStatusIcon() {
        statusIcon = UIImageView(frame: self.activityIndicator.frame)
        statusIcon?.image = self.statusImage
        self.scrollView.addSubview(statusIcon!)
    }
}

extension EnrollmentStatusViewController {
    
    fileprivate struct RefreshStatusTimer {
        static var timer: Timer?
    }
    
    @objc func loadData() {
        EnrollmentService.getEnrollmentStatus(deviceId: self.device.id, success: { (enrollStatus) in
            // Remove error view
            self.errorView?.removeFromSuperview()
            self.errorView = nil
            
            let status = EnrollStatusViewModel(enrollStatus: enrollStatus)
            if self.enrollStatus == nil {
                self.renderView(status: status)
            }
            self.enrollStatus = status
            self.activityIndicator?.startAnimating()

        }) { (err) in
            // TODO
            //VKLog(err)
            self.activityIndicator?.stopAnimating()
            self.showErrorView(with: err)
        } errData: { (errorMeta) in
            self.showErrorHandlingAlert(title: errorMeta.title ?? "", message: errorMeta.message ?? "", suggestions: errorMeta.suggestions ?? [])
        }
    }
    
    func showErrorView(with message: String) {
        if errorView != nil || self.statusView != nil {
            return
        }
        errorView = VUIErrorView(frame: self.view.bounds, title: "Error".localized(), message: message)
        errorView?.callback = { [weak self] in
            self?.loadData()
        }
        self.view.addSubview(errorView!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RefreshStatusTimer.timer?.invalidate()
    }
}
