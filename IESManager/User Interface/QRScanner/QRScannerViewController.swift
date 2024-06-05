//
//  QRScannerViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/8/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRScannerDelegate: AnyObject {
    func didScanCode(code: String)
    func noCamerAccess(status: AVAuthorizationStatus)
}

class QRScannerViewController: UIViewController {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var overlayView: UIView!
    
    var rectOfInterest: CGRect? //To allow scanning only to a part of the screen
    
    weak var delegate: QRScannerDelegate?
    
    convenience init(delegate: QRScannerDelegate, rectOfInterest: CGRect? = nil) {
        self.init()
        self.delegate = delegate
        self.rectOfInterest = rectOfInterest
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.vBackgroundColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession == nil {
            let authStatus = checkCameraAccess()
            switch authStatus {
            case AVAuthorizationStatus.authorized:
                setUpScanner()
            case AVAuthorizationStatus.denied:
                self.delegate?.noCamerAccess(status: authStatus)
            case AVAuthorizationStatus.notDetermined:
                requireCameraAccess()
            default:
                self.delegate?.noCamerAccess(status: authStatus)
            }
        }
        
        startScanner()
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
    
    // MARK: - Camera Access
    
    func checkCameraAccess() -> AVAuthorizationStatus {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return authStatus
    }
    
    private func requireCameraAccess() {
#if targetEnvironment(simulator)
        // Simulator
#else
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            DispatchQueue.main.async {
                if granted {
                    self.setUpScanner()
                }else {
                    self.delegate?.noCamerAccess(status: AVAuthorizationStatus.denied)
                }
            }
        }
#endif

    }
    
    func setUpScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        var videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
        }catch {
            //Handle error
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } else {
            self.delegate?.noCamerAccess(status: AVAuthorizationStatus.notDetermined)
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        if let _ = rectOfInterest {
            metadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest!)
            
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer?.frame = view.bounds
        self.overlayView?.removeFromSuperview()
        self.overlayView = nil
        self.renderFocusView()

    }

}

// MARK: - AVCapture Delegate
extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            return
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            self.delegate?.didScanCode(code: stringValue)
        }
    }
}

// MARK: - Focus View
extension QRScannerViewController {
    
    func renderFocusView() {
        if checkCameraAccess() != .authorized || self.rectOfInterest == nil {
            // If no camera access, do nothing
            return
        }
        
        overlayView = UIView(frame: self.view.bounds)
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.55
        self.view.addSubview(overlayView)
        
        //Add mask to the overlayview
        let maskPath = CGMutablePath()
        maskPath.addRoundedRect(in: self.rectOfInterest!, cornerWidth: 8, cornerHeight: 8)
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskPath
        borderLayer.lineWidth = 3
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = overlayView.bounds
        overlayView.layer.addSublayer(borderLayer)
        
        maskPath.addRect(self.view.bounds)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = overlayView.bounds
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.path = maskPath
        overlayView.layer.mask = maskLayer
        
    }
}

