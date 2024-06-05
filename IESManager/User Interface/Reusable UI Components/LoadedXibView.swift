//
//  LoadedXibView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 16/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

// Loads a xib file of the same name
// In IB just connect the root view to xibView
// Define other views in the subclass
class LoadedXibView: UIView {
    @IBOutlet var xibView: UIView!
    
    private var typeName: String {
        return String(describing: type(of: self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXibRootView()
        loaded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXibRootView()
        loaded()
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        loadXibRootView()
        loaded()
    }
    
    private func loadXibRootView() {
        xibView = Bundle.main.loadNibNamed(typeName,
                                           owner: self,
                                           options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
    }
    
    /// Implement in subclasses to be notified when loading completes
    public func loaded() {
        setTheme() // calls subclass if implemented
        // Nothing to do there.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        // Nothing to do here
    }
}
