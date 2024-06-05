//
//  UpdatingConfigIndicatorView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 25/09/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit

protocol UpdatingConfigIndicatorViewDelegate: UIViewController {
    func indicatorViewTimedOutUserRequestTryAgain()
}

class UpdatingConfigIndicatorView: UIView {
    enum InidcatorStates {
        case uploading
        case completeWithSuccess
        case completeWithSuccessNoPop
        case completeWithError
    }
    
    private let animationDuration: Double = 0.3
    
    @IBOutlet private weak var xibView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var indicatorBackingView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var checkbox: UIImageView!
    
    private var hostViewController: UIViewController?
    private var timeOutTimer: Timer?
    
    private var state: InidcatorStates?
    private weak var delegate: UpdatingConfigIndicatorViewDelegate?
    
    // MARK: - Indicator visualisation
    
    var labelText: String {
        get { return titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }
    
    func updateIndicator(state: InidcatorStates, host: UpdatingConfigIndicatorViewDelegate?) {
        self.state = state
        delegate = host
        
        DispatchQueue.main.async {
            if host != nil {
                self.hostViewController = host
            }
            
            self.activityIndicator.stopAnimating()
            
            switch state {
            case .uploading:
                self.fadeIn()
                
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                self.showCheckbox(show: false)
                
                // Start a 30 second timer. If it completes that show finish with error
                self.timeOutTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false, block: { (timer) in
                    if state == .uploading {
                        self.updateIndicator(state: .completeWithError, host: self.delegate)
                        self.reportTimeOut()
                    }
                })
                
                break
            case .completeWithSuccess:
                
                self.activityIndicator.isHidden = true
                self.showCheckbox(show: true)
                self.timeOutTimer?.invalidate()
                
                let delay = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.fadeOut(dismissHost: true)
                }
                
                break
            case .completeWithSuccessNoPop:
                self.activityIndicator.isHidden = true
                self.showCheckbox(show: true)
                self.timeOutTimer?.invalidate()
                
                let delay = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.fadeOut(dismissHost: false)
                }
                break
            case .completeWithError:
                self.fadeOut(dismissHost: false)
                self.timeOutTimer?.invalidate()
                break
            }
        }
    }
    
    private func reportTimeOut() {
        delegate?.indicatorViewTimedOutUserRequestTryAgain()
    }
    
    private func showCheckbox(show: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.checkbox.alpha = show ? 1.0 : 0.0
        }
    }
    
    private func fadeIn() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 1.0
            self.isUserInteractionEnabled = true
        }) { (success) in
            
        }
    }
    
    private func fadeOut(dismissHost: Bool) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 0.0
            
        }) { (success) in
            self.isUserInteractionEnabled = false
            
            if dismissHost == true {
                if let host = self.hostViewController {
                    host.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("UpdatingConfigIndicatorView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        
        setUpViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("UpdatingConfigIndicatorView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        indicatorBackingView.layer.borderColor = Utils.globalTint().cgColor
        indicatorBackingView.layer.borderWidth = 4
        indicatorBackingView.layer.cornerRadius = 20.0
        
        indicatorBackingView.layer.shadowColor = UIColor.darkGray.cgColor
        indicatorBackingView.layer.shadowOpacity = 1
        indicatorBackingView.layer.shadowOffset = CGSize.zero
        indicatorBackingView.layer.shadowRadius = 10
        
    }
    
}
