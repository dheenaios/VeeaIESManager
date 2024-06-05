//
//  MoreInfoBanner.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 14/06/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class MoreInfoBanner: UIView {
    private var xibView: UIView?
    private var observer: (() -> Void)?
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!
    
    @IBAction func moreInfoButtonTapped(_ sender: Any) {
        guard let o = observer else { return }
        o()
    }
    
    func observerTaps(observer: @escaping (() -> Void)) {
        self.observer = observer
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("MoreInfoBanner", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("MoreInfoBanner", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
