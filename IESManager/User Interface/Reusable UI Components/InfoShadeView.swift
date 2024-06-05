//
//  InfoShadeView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 09/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

class InfoShadeView: UIView {
    
    private var tapObserver: (() -> Void)?
    private var button: UIButton?
    
    init(frame: CGRect,
         backgroundColor: UIColor,
         text: String) {
        super.init(frame: frame)

        // Add an inner view
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(container)
        
        container.topAnchor.constraint(equalTo: topAnchor, constant: 8.0).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0).isActive = true
        container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0).isActive = true
        container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0).isActive = true
        container.alpha = 0.9
        container.backgroundColor = backgroundColor
        container.layer.cornerRadius = 10.0
        container.clipsToBounds = true
        container.layer.borderWidth = 1.0
        container.layer.borderColor = UIColor.lightGray.cgColor
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4.0).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4.0).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4.0).isActive = true
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4.0).isActive = true
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = FontManager.regular(size: 15)
        label.numberOfLines = 4
        label.textAlignment = .center
        label.text = text
    }
    
    func addTapObserver(tapped: @escaping () -> Void) {
        // TODO: Doesnt work
        
        
        tapObserver = tapped
        button = UIButton(frame: self.bounds)
        button!.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        self.addSubview(button!)
    }
    
    @objc func handleTap() {
        //print("Tapped")
        
        guard let t = tapObserver else { return }
        t()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
