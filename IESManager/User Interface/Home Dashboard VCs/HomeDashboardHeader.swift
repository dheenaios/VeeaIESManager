//
//  HomeDashboardHeader.swift
//  IESManager
//
//  Created by Richard Stockdale on 07/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

protocol HomeDashboardHeaderDelegate {
    func preparingTapped()
    func errorTapped()
    func cellularLearnMoreTapped()
}

class HomeDashboardHeader: LoadedXibView {
    var delegate: HomeDashboardHeaderDelegate?
    
    var vm: HomeDashboardHeaderViewModel?

    @IBOutlet weak var meshButton: UIButton!
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var deviceConnectionsLabel: UILabel!
    
    // Preparing
    @IBOutlet weak var preparingView: UIView!
    @IBOutlet weak var preparingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var preparingText: UILabel!
    
    // Warning
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorImage: UIImageView!
    @IBOutlet weak var errorText: UILabel!
    
    // Cellular State
    @IBOutlet weak var cellularView: UIView!
    @IBOutlet weak var signalStrengthImage: UIImageView!
    @IBOutlet weak var cellularLabel: UILabel!
    @IBOutlet weak var networkModeImage: UIImageView!
    @IBOutlet weak var cellLearnMoreButton: UIButton!

    override func loaded() {
        super.loaded()
        setFontsAndColors()
        drawMeshButton()
        setMeshText()
        
        preparingSpinner.startAnimating() // Temp
    }
    
    private func drawMeshButton() {
        meshButton.backgroundColor = .clear
        meshButton.layer.cornerRadius = 5
        meshButton.layer.borderWidth = 1
        meshButton.layer.borderColor = InterfaceManager.shared.cm.themeTint.colorForAppearance.cgColor
        meshButton.titleLabel?.font = FontManager.medium(size: 15)
    }
    
    func setUp(config: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig) {
        if vm == nil {
            vm = HomeDashboardHeaderViewModel(config: config)
            vm?.addAsObserver {_ in
                self.updateContent()
            }
            
            self.updateContent()
            self.setFontsAndColors()
            return
        }
        
        vm?.configure(config)
        updateContent()
    }

    private func setFontsAndColors() {

        let cm = InterfaceManager.shared.cm
        
        // Info Label
        deviceConnectionsLabel.font = FontManager.regular(size: 18)
        deviceConnectionsLabel.setExistingTextWithLineSpacing()
        
        // Preparing Views
        preparingSpinner.color = cm.themeTint.colorForAppearance
        preparingText.textColor = cm.themeTint.colorForAppearance
        
        // Error Views
        errorImage.image = errorImage.image?.withRenderingMode(.alwaysTemplate)
        errorImage.tintColor = cm.statusRed.colorForAppearance
        errorText.textColor = cm.statusRed.colorForAppearance
        errorText.font = FontManager.regular(size: 18)
        errorImage.tintColor = cm.statusRed.colorForAppearance
        
        cellularLabel.font = FontManager.regular(size: 18)
        cellularLabel.textColor = vm?.connectedTextColor.colorForAppearance
        cellularLabel.text = vm?.connectionText
        cellLearnMoreButton.titleLabel?.font = FontManager.medium(size: 17)
        cellLearnMoreButton.titleLabel?.textColor = cm.themeTint.colorForAppearance
        cellLearnMoreButton.isHidden = !(vm?.showCellLearnMore ?? true)

    }

    @IBAction func cellularLearnMoreButtonTapped(_ sender: Any) {
        delegate?.cellularLearnMoreTapped()
    }

    
    @IBAction func preparingButtonTapped(_ sender: Any) {
        delegate?.preparingTapped()
    }
    
    @IBAction func errorButtonTapped(_ sender: Any) {
        delegate?.errorTapped()
    }
}

// MARK: - Content
extension HomeDashboardHeader {
    private func updateContent() {
        setMeshText()
        showHideViews()
        updateCellularImage()
        cellularLabel.text = vm?.connectionText
        cellularLabel.textColor = vm?.connectedTextColor.colorForAppearance
    }
    
    private func showHideViews() {
        if vm!.showHealthy {
            preparingView.isHidden = true
            errorView.isHidden = true
        }
        else if vm!.showPreparing {
            preparingView.isHidden = false
            errorView.isHidden = true
        }
        else if vm!.showError {
            preparingView.isHidden = true
            errorView.isHidden = false
        }
        else if vm!.isNotAvailable {
            preparingView.isHidden = true
            errorView.isHidden = false
        }
        
        cellularView.isHidden = !vm!.showCellularSignal
    }
    
    private func updateCellularImage() {
        // Signal strength
        if let image = vm?.cellularDataSignalImage {
            signalStrengthImage.image = image
        }

        networkModeImage.image = vm?.networkTypeImage
    }
    
    private func setMeshText() {
        helloLabel.text = vm?.greeting
        deviceConnectionsLabel.text = vm?.deviceConnectionLabelText
    }
}

enum CellularStatusAndStrength: Int {
    case noCellularSupport
    case noCellularSubscription
    case bar0
    case bar1
    case bar2
    case bar3
    case bar4
    case bar5
}

class HomeDashboardHeaderViewModel: HomeUserBaseViewModel {
    struct HomeDashboardHeaderConfig {
        enum HeaderState {
            case inError
            case isPreparing
            case healthy
            case notAvailable // The MEN is not connected to the MAS
        }

        let cellular: CellularStatusAndStrength
        let headerState: HeaderState
        let usersName: String
        let numberOfHubs: Int
        let numberOfHosts: Int
        let networkMode: String?
    }
    
    private var config: HomeDashboardHeaderConfig
        
    init(config: HomeDashboardHeaderConfig) {
        self.config = config
    }
    
    func configure(_ config: HomeDashboardHeaderConfig) {
        self.config = config
        informObserversOfChange(type: .dataModelUpdated)
    }
    
    // MARK: Info Text
    var greeting: String {
        return "Hello".localized() + " " + config.usersName + "!"
    }
    
    var deviceConnectionLabelText: String {
        if showPreparing {
            return "Preparing your network.\nThis might take up to an hour.".localized()
        }
        else if showError {
            return "Unable to prepare your network.".localized()
        }
        else if isNotAvailable {
            return "Unable to connect to your network".localized()
        }
        
        // HEALTHY
        if config.numberOfHubs == 1 {
            return hostNumberText + "\(config.numberOfHubs)" + " " + "VeeaHub in location".localized()
        }
        
        return hostNumberText + "\(config.numberOfHubs)" + " " + "VeeaHubs in location".localized()
    }
    
    private var hostNumberText: String {
        switch config.numberOfHosts {
        case 0:
            return ""
        case 1:
            return "1 device is connected\n"
        default:
            return "\(config.numberOfHosts) devices connected\n"
        }
    }
    
    // MARK: Mesh State
    var showHealthy: Bool {
        config.headerState == .healthy
    }
    
    var showPreparing: Bool {
        config.headerState == .isPreparing
    }
    
    var showError: Bool {
        config.headerState == .inError
    }

    var isNotAvailable: Bool {
        config.headerState == .notAvailable
    }
    

}

// MARK: -  Cellular model
extension HomeDashboardHeaderViewModel {

    /// Show or hide the cellular info view
    var showCellularSignal: Bool {
        config.cellular != .noCellularSupport
    }

    var connectionText: String {
        // Check if they're subscribed
        if config.cellular == .noCellularSupport {
            return "Cellular Disabled".localized()
        }

        return "Connected".localized()
    }

    var showCellLearnMore: Bool {
        return config.cellular == .noCellularSupport
    }

    var connectedTextColor: DynamicColor {
        if config.cellular == .noCellularSupport {
            return InterfaceManager.shared.cm.buttonOrange1
        }

        return InterfaceManager.shared.cm.text1
    }

    var cellularDataSignalImage: UIImage? {
        switch config.cellular {
        case .noCellularSupport:
            return nil
        case .noCellularSubscription:
            return UIImage(named: "home_strength_bars_disabled")
        case .bar0:
            return UIImage(named: "home_strength_bars_0")
        case .bar1:
            return UIImage(named: "home_strength_bars_1")
        case .bar2:
            return UIImage(named: "home_strength_bars_2")
        case .bar3:
            return UIImage(named: "home_strength_bars_3")
        case .bar4:
            return UIImage(named: "home_strength_bars_4")
        case .bar5:
            return UIImage(named: "home_strength_bars_5")
        }
    }

    var networkTypeImage: UIImage? {
        guard let networkMode = config.networkMode else { return nil }
        if config.cellular == .noCellularSupport {
            return nil
        }

        switch networkMode.lowercased() {
        case "2G".lowercased():
            return UIImage(named: "2G Logo")
        case "3G".lowercased():
            return UIImage(named: "3G Logo")
        case "4G".lowercased():
            return UIImage(named: "4G Logo")
        case "5G".lowercased():
            return UIImage(named: "5G Logo")
        default:
            return nil
        }
    }
}
