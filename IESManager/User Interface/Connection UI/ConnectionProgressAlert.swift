//
//  ConnectionProgressAlert.swift
//  ConnectionProgressView
//
//  Created by Richard Stockdale on 13/10/2020.
//

import UIKit


class ConnectionProgressAlert: UIView {

    @IBOutlet var rootView: UIView!
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var nodeNameLabel: UILabel!
    @IBOutlet weak var nodeSerialLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var connectUsingLabel: UILabel!
    
    typealias CompletionBlock = (SuccessAndOptionalMessage) -> Void
    private var completionBlock: CompletionBlock?
    private var cancelled = false
    private var sending = false
    
    private var lastConnectionAttempt: Date?
    private var nodeSerial: String?
    
    var negotiator: ConnectionNegotiator?
    
    public func connectToHub(hub: VeeaHubConnection, completion: @escaping CompletionBlock) {
        cancelled = false
        progressView.progress = 0.0
        self.completionBlock = completion
        
        nodeNameLabel.text = hub.hubDisplayName
        nodeSerialLabel.text = hub.hubId ?? "?"
        nodeSerial = hub.hubId
        
        negotiator = ConnectionNegotiator.init(withModel: hub,
                                               updateDelegate: self)
        
        updateUI()
        
        if let lastConnectionAttempt = lastConnectionAttempt {
            if lastConnectionAttempt.inLast(seconds: 2) || sending {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.request()
                }
            }
            else {
                request()
            }
        }
        else { request() }
    }
    
    private func request() {
        sending = true
        lastConnectionAttempt = Date()
        negotiator?.startConnectionAttempts()
    }
    
    public func updateUI() {
        guard let negotiator = negotiator else {
            return
        }
        
        if let progress = negotiator.progress {
            progressView.setProgress(progress, animated: true)
        }
        
        connectUsingLabel.text = negotiator.connectUsingLabelText
    }
    
    
    // MARK: - Init and Set up
    
    @IBAction func cancelTapped(_ sender: Any) {
        cancelled = true
        negotiator = nil
        tearDown()
    }
    
    public func tearDown() {
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
            self.rootView.alpha = 0.0
        }) { (finished) in
            self.removeFromSuperview()
            
            self.rootView.alpha = 1.0
            self.alertView.alpha = 1.0
        }
    }
    
    private func setViews() {
        alertView.layer.cornerRadius = 15;
        alertView.layer.masksToBounds = true;
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        rootView = Bundle.main.loadNibNamed("ConnectionProgressAlert", owner: self, options: nil)![0] as? UIView
        rootView?.frame = bounds
        addSubview(rootView!)
        setViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rootView = Bundle.main.loadNibNamed("ConnectionProgressAlert", owner: self, options: nil)![0] as? UIView
        rootView?.frame = bounds
        addSubview(rootView!)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ConnectionProgressAlert: ConnectionNegotiatorCallbacks {
    func connectionAttemptsFinishedSuccessfully() {
        progressView.setProgress(1.0, animated: false)
        
        if let hubId = negotiator?.connection?.hubId,
            let nodeSerial = nodeSerial {
            if hubId != nodeSerial {
                self.connectionAttemptsFinishedFailed(message: "Too many requests. Please wait a moment and try again.")
                sending = false
                self.negotiator = nil
                return
            }
        }
        
        self.tearDown()
        self.sending = false
        
        if !self.cancelled && self.negotiator != nil {
            self.negotiator = nil
            if let completionBlock = self.completionBlock {
                completionBlock((true, nil))
                self.completionBlock = nil
            }
        }
    }
    
    func connectionAttemptsFinishedFailed(message: String) {
        sending = false
        progressView.setProgress(0.5, animated: true)
        
        let delay = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.completionBlock!((false, message))
        }
    }
    
    func shouldUpdateUI() {
        updateUI()
    }
}
