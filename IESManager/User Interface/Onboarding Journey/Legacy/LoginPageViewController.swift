//
//  LoginPageViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 12/27/18.
//  Copyright © 2018 Veea. All rights reserved.
//

import UIKit

class LoginPageViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var pageIndicator: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        // ScrollView
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.scrollView.frame.size.height = self.view.bounds.height * 0.7
        self.view.addSubview(scrollView)
        self.scrollView.backgroundColor = .clear
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.delegate = self
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.populatePages()
        
        // Page Control
        let pagerHeight: CGFloat = 40
        pageIndicator = UIPageControl()
        pageIndicator.numberOfPages = 4
        pageIndicator.currentPage = 0
        pageIndicator.frame = CGRect(x: 0,
                                     y: self.scrollView.bottomEdge - pageIndicator.frame.height - pagerHeight,
                                     width: 200,
                                     height: pagerHeight)
        
        pageIndicator.centerInView(superView: self.view, mode: .horizontal)
        self.view.addSubview(pageIndicator)
    }
    
    func populatePages() {
        let page1 = LoginPageInfoView(frame: self.scrollView.bounds, title: "Control your VeeaHub with ease".localized(), info: "The VeeaHub Manager app enables you to activate and manage your VeeaHubs directly from your mobile device.".localized(), icon: UIImage(named: "veeaLogo"))
        self.scrollView.addSubview(page1)
        self.scrollView.contentSize.width = page1.frame.width
        
        let page2 = LoginPageInfoView(frame: CGRect(x: self.scrollView.contentSize.width, y: 0, width: self.scrollView.bounds.width, height: self.scrollView.bounds.height), title: "Add and manage VeeaHubs", info: "The VeeaHub Manager app allows you to add and manage the VeeaHubs you own with ease.".localized(), icon: #imageLiteral(resourceName: "login-gears-icon"))
        self.scrollView.addSubview(page2)
        self.scrollView.contentSize.width += page2.frame.width
        
        let page3 = LoginPageInfoView(frame: CGRect(x: self.scrollView.contentSize.width, y: 0, width: self.scrollView.bounds.width, height: self.scrollView.bounds.height), title: "Register with a Veea Account", info: "Create a Veea account to gain access to the Veea Network.".localized(), icon: #imageLiteral(resourceName: "login-user-icon"))
        self.scrollView.addSubview(page3)
        self.scrollView.contentSize.width += page3.frame.width
        
        let page4 = LoginPageInfoView(frame: CGRect(x: self.scrollView.contentSize.width, y: 0, width: self.scrollView.bounds.width, height: self.scrollView.bounds.height), title: "Stuck? \n Help is here", info: "The VeeaHub Manager app allows you to view details of your hubs and get help right from the app.".localized(), icon: #imageLiteral(resourceName: "login-help-icon"))
        self.scrollView.addSubview(page4)
        self.scrollView.contentSize.width += page3.frame.width
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

extension LoginPageViewController: UIPageViewControllerDelegate {
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 4
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

// MARK: - UIScrollViewDelegate
extension LoginPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //NADA
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        let page: Int = Int(xOffset/scrollView.frame.width)
        // Upadte page indicator on scroll to show current page
        self.pageIndicator.currentPage = page
    }
}
