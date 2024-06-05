//
//  TypeSelector.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 20/05/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class TypeSelector: UIView {
    
    @IBOutlet var xibView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    typealias CompletionBlock = (String, Int) -> Void
    
    var isEnabled: Bool {
        get { return menuButton.isEnabled }
        set {
            menuButton.isEnabled = newValue
            value.alpha = newValue ? 1.0 : 0.3
        }
    }
    
    private var completionBlock: CompletionBlock?
    private var options = [String]()
    private weak var host: UIViewController?
    
    public var selectedItem: String? {
        didSet {
            self.value.text = selectedItem
        }
    }
    public var selectedIndex: Int? {
        didSet {
            if let i = selectedIndex {
                self.value.text = options[i]
            }
        }
    }
    
    private var titleText: String {
        didSet { title.text = titleText }
    }
    
    private var alertMessageText: String = ""
    
    public func configure(title: String,
                          alertMessage: String,
                          options: [String],
                          initialSelection: Int,
                          hostViewController: UIViewController,
                          completion: @escaping CompletionBlock) {
        self.completionBlock = completion
        self.titleText = title
        self.alertMessageText = alertMessage
        self.options = options
        self.host = hostViewController
        
        self.selectedItem = self.options[initialSelection]
        self.selectedIndex = initialSelection
    }
    
    @objc func buttonTapped(_ sender: Any) {
        selectType()
    }
    
    private func selectType() {
        var style = UIAlertController.Style.actionSheet
        if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
            style = UIAlertController.Style.alert
        }
        
        let alert = UIAlertController(title: self.titleText,
                                      message: self.alertMessageText,
                                      preferredStyle: style)
        
        // Loop through the options
        for (index, option) in options.enumerated() {
            alert.addAction(UIAlertAction(title: option,
                                          style: .default,
                                          handler: { (alert) in
                                            self.selectedItem = option
                                            self.selectedIndex = index
                                            self.completionBlock!(option, index)
                                          }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (alert) in
            // Handle
        }))
        
        host?.present(alert, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("TypeSelector", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        menuButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        titleText = ""
    }
    
    override init(frame: CGRect) {
        titleText = ""
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("TypeSelector", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        menuButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        titleText = ""
        super.init(coder: aDecoder)
    }

}
