//
//  HomePreparingNodeViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 10/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class HomePreparingNodeViewController: HomeUserBaseViewController {

    @IBOutlet weak var stack: UILabel!
    
    // Header
    @IBOutlet weak var headerStackLabel: UILabel!
    @IBOutlet weak var headerStackButton: UIButton!
    
    // Progress View
    @IBOutlet weak var progressPanelView: PreparingProgressView!
    @IBOutlet weak var bottomProgressPanelDivider: UIView!
    
    // Error State View
    @IBOutlet weak var errorStateView: UIView!
    @IBOutlet weak var fixItButton: CurvedButton!
    @IBOutlet weak var contactCustomerSupportButton: UIButton!
    
    // Footer
    @IBOutlet weak var bottomDivider: UIView!
    @IBOutlet weak var footerInfoLabel: UILabel!
    @IBOutlet weak var cancelRemoveButton: UIButton!
    
    private var vm: HomePreparingNodeViewModel!
    
    static func new(nodeTableCellModel: NodeTableCellModel) -> HomePreparingNodeViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomePreparing.rawValue, bundle: nil).instantiateViewController(withIdentifier: "HomePreparingNodeViewController") as! HomePreparingNodeViewController
        vc.vm = HomePreparingNodeViewModel(nodeTableCellModel: nodeTableCellModel, delegate: vc)
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = vm.title
        progressPanelView.update(status: nil)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.startTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.stopTimer()
    }
    
    override func setTheme() {
        super.setTheme()
        headerStackLabel.textColor = cm.text1.colorForAppearance
        headerStackLabel.font = FontManager.light(size: 18)
        headerStackLabel.setTextWithDefaultSpacing(text: vm.headerText)
        
        headerStackButton.titleLabel?.font = FontManager.bigButtonText
        headerStackButton.tintColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
        
        footerInfoLabel.textColor = cm.text1.colorForAppearance
        footerInfoLabel.font = FontManager.light(size: 18)
        headerStackLabel.setTextWithDefaultSpacing(text: headerStackLabel.text ?? "")

        cancelRemoveButton.tintColor = InterfaceManager.shared.cm.statusRed.colorForAppearance
        cancelRemoveButton.titleLabel?.font = FontManager.bigButtonText
        
        fixItButton.setTitleColor(cm.themeTint.colorForAppearance, for: .normal)
        fixItButton.borderColor = cm.themeTint.colorForAppearance
        fixItButton.fillColor = .white
        fixItButton.titleLabel?.font = FontManager.bigButtonText
        
        contactCustomerSupportButton.titleLabel?.font = FontManager.bigButtonText

    }
    
    @IBAction func headerStackButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func fixItTapped(_ sender: Any) {
        
    }

    @IBAction func contactCustomerSupportTapped(_ sender: Any) {
        
    }
    
    @IBAction func cancelRemoveButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Remove VeeaHub".localized(),
                                           message: "Are you sure you want to remove this VeeaHub?".localized(),
                                           preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "CANCEL".localized(),
                                           style: .cancel,
                                           handler: nil))
        alert.addAction(UIAlertAction(title: "REMOVE".localized(),
                                           style: .destructive,
                                           handler: { [weak self] (action) in
            self?.showWorkingAlert(show: true)
            self?.vm.unenrollHub()
        }))

        present(alert, animated: true, completion: nil)
    }
    
    private func updateState() {
        progressPanelView.update(status: vm.enrollmentState)

        guard let state = vm.enrollmentState else {
            return
        }
        
        if state.didFail {
            setErrorState()
            return
        }
        
        if state.percentage == 100 {
            setCompleteState()
            return
        }
        
        setUpdatingState()
    }
}

// MARK: - State management
extension HomePreparingNodeViewController {

    private func setErrorState() {
        headerStackLabel.setTextWithDefaultSpacing(text: vm.headerText)
        footerInfoLabel.isHidden = true
        errorStateView.isHidden = false
        bottomDivider.isHidden = false
        headerStackButton.isHidden = false
        cancelRemoveButton.isHidden = false
    }
    
    private func setUpdatingState() {
        headerStackLabel.setTextWithDefaultSpacing(text: vm.headerText)
        footerInfoLabel.isHidden = false
        errorStateView.isHidden = true
        bottomDivider.isHidden = false
        bottomProgressPanelDivider.isHidden = false
        headerStackButton.isHidden = false
        cancelRemoveButton.isHidden = false
    }
    
    private func setCompleteState() {
        headerStackLabel.setTextWithDefaultSpacing(text: vm.headerText)
        errorStateView.isHidden = true
        footerInfoLabel.isHidden = true
        bottomDivider.isHidden = true
        bottomProgressPanelDivider.isHidden = true
        headerStackButton.isHidden = true
        cancelRemoveButton.isHidden = true
    }
}

extension HomePreparingNodeViewController: HomePreparingNodeViewModelDelegate {
    func enrollmentStateUpdated() {
        updateState()
    }
    
    func unenrollCompletedSuccessfully() {
        showWorkingAlert(show: false)
        self.navController.popToRootViewController(animated: true)
    }
    
    func unenrollCompletedWithError(error: String) {
        showWorkingAlert(show: false)
        showInfoAlert(title: "Error", message: error)
    }
}

protocol HomePreparingNodeViewModelDelegate: AnyObject {
    func unenrollCompletedSuccessfully()
    func unenrollCompletedWithError(error: String)
    
    func enrollmentStateUpdated()
}

class HomePreparingNodeViewModel {
    private let nodeTableCellModel: NodeTableCellModel
    private let device: VHMeshNode
    private var refreshTimer: Timer?
    
    private weak var delegate: HomePreparingNodeViewModelDelegate?
    
    var enrollmentState: EnrollStatusViewModel?
    
    init(nodeTableCellModel: NodeTableCellModel, delegate :HomePreparingNodeViewModelDelegate) {
        self.delegate = delegate
        self.nodeTableCellModel = nodeTableCellModel
        self.device = self.nodeTableCellModel.device
        
        startTimer()
        refreshTimer?.fire()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }

    func startTimer() {
        if refreshTimer == nil {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true, block: { (timer) in
                self.loadData()
            })

            return
        }

        if refreshTimer!.isValid { return }

        if !refreshTimer!.isValid {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true, block: { (timer) in
                self.loadData()
            })
        }
    }

    func stopTimer() {
        refreshTimer?.invalidate()
    }

    var title: String {
        return nodeTableCellModel.device.name.replacingOccurrences(of: "_", with: " ")
    }
    
    var headerText: String {
        let defaultText = "This VeeaHub is installing required software updates and will be ready soon.".localized()
        
        guard let state = enrollmentState else {
            return defaultText
        }

        if state.didFail {
            return "Instalation has failed. Do not worry though, find how to fix it by clicking on the button below.".localized()
        }
        
        if state.percentage == 100 {
            return "This VeeaHub is ready to use.".localized()
        }
        
        return defaultText
    }
    
    func unenrollHub() {
        HubRemover.remove(node: self.device) { (success, errorString) in
            if success {
                self.delegate?.unenrollCompletedSuccessfully()
                return
            }
            
            self.delegate?.unenrollCompletedWithError(error: errorString ?? "Unknown Error")
        }
    }
    
    func loadData() {
        EnrollmentService.getEnrollmentStatus(deviceId: self.device.id, success: { (enrollStatus) in
            self.enrollmentState = EnrollStatusViewModel(enrollStatus: enrollStatus)
            self.delegate?.enrollmentStateUpdated()
        }) { (err) in
            // Nothing to do here. Just keep checking.
        } errData: { (errorMetaData) in
            
        }
    }
}
