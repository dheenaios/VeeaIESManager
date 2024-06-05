//
//  ScanCodeViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 22/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import AVFoundation

class ScanCodeViewController: OnboardingBaseViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var targetView: UIView!
    
    private var scannedCode = false
    
    static func new() -> ScanCodeViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserEnrollment.rawValue, bundle: nil).instantiateViewController(withIdentifier: "ScanCodeViewController") as! ScanCodeViewController
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan QR Code".localized()
        setUpTargetView()
    }
    
    private func setUpTargetView() {
        targetView.backgroundColor = .clear
        targetView.layer.borderWidth = 1.0
        targetView.layer.borderColor = UIColor.gray.cgColor
        targetView.layer.cornerRadius = 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession == nil {
            let authStatus = checkCameraAccess()
            switch authStatus {
            case AVAuthorizationStatus.authorized:
                setUpScanner()
            case AVAuthorizationStatus.denied:
                noCameraAccess()
                break
            case AVAuthorizationStatus.notDetermined:
                requireCameraAccess()
            default:
                noCameraAccess()
                break
            }
        }
        
        startScanner()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideBack = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanner()
        
    }
    
    func startScanner() {
        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    func stopScanner() {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func setTheme() {
        super.setTheme()
        
        infoLabel.textColor = cm.text2.colorForAppearance
        infoLabel.font = FontManager.bodyText
        
        helpButton.setTitleColor(cm.themeTint.colorForAppearance, for: .normal)
        helpButton.titleLabel?.font = FontManager.bigButtonText
    }
    
    @IBAction func helpTapped(_ sender: Any) {
        openHelp()
    }
}


// MARK: - Camera Access
extension ScanCodeViewController {
    func checkCameraAccess() -> AVAuthorizationStatus {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return authStatus
    }
    
    private func requireCameraAccess() {
        if Platform.isSimulator { return }
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            DispatchQueue.main.async {
                if granted {
                    self.setUpScanner()
                }
                else {
                    self.openSettings()
                }
            }
        }
    }
    
    func setUpScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        var videoInput: AVCaptureDeviceInput
        
        do { videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice) }
        catch { return }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        }
        else {
            noCameraAccess()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = overlayView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        overlayView.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
}

// MARK: - AVCapture Delegate
extension ScanCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            return
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            if !scannedCode {
                scannedCode = false
                stopScanner()
                authenticateCode(stringValue)
            }
        }
    }
}

// State handling
extension ScanCodeViewController {
    
    func didScanCode(code: String) {
        stopScanner()
        authenticateCode(code)
    }
    
    func noCameraAccess() {

        if Platform.isSimulator { return }

        let alert = UIAlertController(title: "No Camera Access".localized(),
                                      message: "Please provide camera access to scan QR code.".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings".localized(),
                                      style: .default,
                                      handler: { action in
            self.openSettings()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func authenticateCode(_ code: String) {
        let activity = VUIActivityView()
        activity.beginAnimating()
        EnrollmentService.checkDevice(with: code, success: {
            activity.endAnimating(callback: {
                self.pushToNameScreen(hubCode: code)
                self.scannedCode = false
            })
            
        }) { (error) in
            activity.endAnimating(callback: {
                // Show error and start scanner again
                AnalyticsEventHelper.qrCodeScanFailed(reason: error, qrCodeDetails: code)
                self.scannedCode = false
                
                let alert = UIAlertController(title: "Oops!".localized(), message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { (_) in
                    alert.dismiss(animated: true, completion: nil)
                    self.startScanner()
                }))
                self.present(alert, animated: true, completion: nil)
            })
        }errData: { (errorMeta) in
            print("ERROR META::\(errorMeta)")
        }
    }
    
    private func pushToNameScreen(hubCode: String) {
        let nc = self.navigationController as! HomeUserSessionNavigationController // I want this to crash if not true
        nc.newEnrollment.hubQrCode = hubCode
        
        // If we dont have a mesh name we can now make one from the info in the qr code
        if nc.newEnrollment.meshName == nil {
            nc.newEnrollment.meshName = nc.newEnrollment.defaultMeshName
        }
        
        let vc = NameVeeaHubViewController.new()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openHelp() {
        self.navigationController?.present(VUIWebViewController(urlString: "https://www.veea.com/support/section/360003497673/"), animated: true, completion: nil)
    }
}
