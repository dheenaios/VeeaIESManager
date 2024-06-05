//
//  HelpViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 08/08/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit
import Down

class HelpViewController: UIViewController {
    var helpView: DownView?
    private var initialText: String?
    private var initialUrl: URL?
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    public func loadText(textString: String) {
        guard let helpView = helpView else {
            
            // Set this so its there for load
            initialText = textString
            
            return
        }
        
        try? helpView.update(markdownString: textString)
    }
    
    public func loadFromUrl(url: URL) {
        guard let helpView = helpView else {
            initialUrl = url
            return
        }
        
        if let content = loadUrl(url: url) {
            try? helpView.update(markdownString: content)
        }
    }

    override func viewDidLoad() {
        helpView = try? DownView(frame: self.view.bounds,
                                 markdownString: "**Loading**".localized(),
                                 templateBundle: getAssetsBundle())
        
        // Load url or initial text
        if let content = loadUrl(url: initialUrl) {
            try? helpView?.update(markdownString: content)
        }
        else if let it = initialText {
            try? helpView?.update(markdownString: it)
        }
        
        helpView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(helpView!)
    }
    
    private func loadUrl(url: URL?) -> String? {
        guard let url = url else {
            return nil
        }
        
        do {
            let contents = try String(contentsOf: url)
            return contents
        }
        catch { return nil }
    }
    
    private func getAssetsBundle() -> Bundle? {
        let p = Bundle.main.path(forResource: "markdownViewAssets", ofType: "bundle")
        let b = Bundle(path: p!)
        
        return b
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        // Check if we are displayed or or in navigation view.
        // If there is more than 1 this then pop it off
        if navigationController?.viewControllers.count ?? 0 > 1 {
            navigationController?.popViewController(animated: true)
            
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func loadMarkDownStringFromFile(path: String) -> String {
        if let filepath = Bundle.main.path(forResource: path, ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filepath)
                
                return contents
            }
            catch {}
        }
        
        return "Error loading: " + path + ".md"
    }
    
    func loadMarkDownStringFromUrl(url: URL) {
        
    }
    
    func scrollToBottom() {
        if let scrollView = helpView?.scrollView {
            let bottomOffset = CGPoint(x: 0, y: (scrollView.contentSize.height - scrollView.bounds.size.height + 50))
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
}
