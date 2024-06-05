//
//  AuthenticateDeviceViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/8/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import AVFoundation
import SharedBackendNetworking

protocol AuthenticateDeviceDelegate {
    func didAuthenticateDevice(with code: String)
}

class AuthenticateDeviceViewController: VUIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .advanced_veeahub_settings

    var contentView: UIView!
    var scannerVC: QRScannerViewController?
    var delegate: AuthenticateDeviceDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonTitle()
        let titleString = "Authenticate VeeaHub".localized()
        self.title = titleString
        
        contentView = UIView(frame: CGRect(x: 0, y: self.navbarMaxY, width: self.view.bounds.width, height: UIConstants.Margin.top))
        
        let titleView = TitleViewWithImage(icon: UIImage(named: "OnboardingStep2") ,title: titleString, subtext: "Please scan the QR code on the back of the VeeaHub to authenticate it.".localized())
        titleView.frame.origin.y = contentView.frame.height
        contentView.push(titleView)
        contentView.addOffset(UIConstants.Margin.side * 2)
        
        if Target.currentTarget.isRobotBuild {
            let helpInfoView = InfoWithButtonView(infoText: "Can't find your QR code?".localized(), buttonTitle: "Enter manually (UI Testing only)")
            helpInfoView.frame.origin.y = contentView.frame.height
            helpInfoView.buttonCallBack = {[weak self] in
                self?.enterSerialManually()
            }
            contentView.push(helpInfoView)
            contentView.addOffset(UIConstants.Margin.top)
        }
        
        self.view.addSubview(contentView)
        
        self.renderScanner()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scannerVC?.startScanner()
        recordScreenAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scannerVC?.stopScanner()
    }
    
    
    func renderScanner() {
        let scannerHeight = self.view.bounds.height - contentView.frame.height
        // Area of interest for QR scanner
        let rectSize = self.view.bounds.width * 0.6
        let rectX = (self.view.bounds.width * 0.5) - (rectSize * 0.5)
        let rectY = ((scannerHeight - navbarMaxY) * 0.5) - (rectSize * 0.5)
        
        scannerVC = QRScannerViewController(delegate: self, rectOfInterest: CGRect(x: rectX, y: rectY, width: rectSize, height: rectSize))
        scannerVC!.view.frame = CGRect(x: 0, y: self.contentView.bottomEdge, width: self.view.bounds.width, height: scannerHeight)
        self.add(scannerVC!)
        
    }

    func authenticateCode(_ code: String) {
        let activity = VUIActivityView()
        activity.beginAnimating()
        EnrollmentService.checkDevice(with: code, success: {
            activity.endAnimating(callback: {
                self.delegate?.didAuthenticateDevice(with: code)
            })
            
        }) { (error) in
            activity.endAnimating(callback: {
                // Show error and start scanner again
                AnalyticsEventHelper.qrCodeScanFailed(reason: error, qrCodeDetails: code)
                
                let alert = UIAlertController(title: "Oops!".localized(), message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { (_) in
                    alert.dismiss(animated: true, completion: nil)
                    self.scannerVC?.startScanner()
                }))
                self.present(alert, animated: true, completion: nil)
                
            })
        } errData: { (errorMeta) in
            self.showErrorHandlingAlert(title: errorMeta.title ?? "", message: errorMeta.message ?? "", suggestions: errorMeta.suggestions ?? [])
        }
    }
    
    func enterSerialManually() {
        Utils.showInputAlert(from: self,
                             title: "Enter Serial",
                             message: "Enter serial as per the QR code",
                             initialValue: "",
                             okButtonText: "OK") { serial in
            self.authenticateCode(serial)
        }
    }
}

extension AuthenticateDeviceViewController: QRScannerDelegate {
    
    func didScanCode(code: String) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        self.scannerVC?.stopScanner()
        self.authenticateCode(code)
    }
    
    func noCamerAccess(status: AVAuthorizationStatus) {
        let cameraErrorView = VUIErrorView(frame: CGRect(x: 0, y: self.contentView.bottomEdge, width: self.view.bounds.width, height: self.view.bounds.height - self.contentView.bottomEdge), title: "No Camera Access".localized(), message: "Please provide camera access to scan QR code.".localized(), buttonTitle: "Open Settings".localized())
        cameraErrorView.callback = { [weak self] in
            self?.openSettings()
        }
        self.view.addSubview(cameraErrorView)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
