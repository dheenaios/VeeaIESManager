//
//  SignupCompleteViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/3/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class SignupCompleteViewController: VUIViewController {
    
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign Up".localized()
        
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollVerticalStyle(scrollView)
        self.view.addSubview(scrollView)
        
        let contentWidth = self.view.bounds.width - (UIConstants.Margin.side * 2)
        
        let largeTitle = VUILargeTitle(frame: CGRect(x: 0, y: 0, width: contentWidth, height: 0), title: "You are done!".localized())
        largeTitle.centerInView(superView: self.view, mode: .horizontal)
        self.scrollView.push(largeTitle)
        self.scrollView.addOffset(UIConstants.Margin.top)
        
        let info1 = UILabel(frame: CGRect(x: 0, y: 0, width: contentWidth, height: 0))
        info1.text = "Your account has been created. \n Thank you for joining us.".localized()
        multilineCenterLabelStyle(info1)
        info1.centerInView(superView: self.view, mode: .horizontal)
        self.scrollView.push(info1)
        self.scrollView.addOffset(UIConstants.Margin.side)
        
        let info2 = UILabel(frame: CGRect(x: 0, y: 0, width: contentWidth, height: 0))
        info2.text = "Tap on the button below to start using the VeeaHub Manager.".localized()
        multilineCenterLabelStyle(info2)
        info2.centerInView(superView: self.view, mode: .horizontal)
        self.scrollView.push(info2)
        self.scrollView.addOffset(UIConstants.Margin.top * 2)
        
        let button = VUIFlatButton(frame: CGRect(x: UIConstants.Margin.side, y: 0, width: contentWidth, height: 40), type: .green, title: "Start using VeeaHub".localized())
        scrollView.push(button)
        
        centerContent()
    }
    
    func centerContent() {
        let offset = ((scrollView.bounds.height - self.scrollView.contentSize.height) - self.navbarMaxY)/2
        self.scrollView.contentInset.top = offset
    }
    
    // MARK: - Navigation

}
