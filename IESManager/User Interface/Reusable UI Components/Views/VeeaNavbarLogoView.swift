//
//  VeeaNavbarLogoView.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/4/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class VeeaNavbarLogoView: UIView {

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        self.backgroundColor = .clear
        let titleLogo = UIImageView(frame: self.bounds)
        titleLogo.image = UIImage(named: "veeaLogo")
        self.addSubview(titleLogo)
    }

}
