//
//  ErrorHandlingAlert.swift
//  ErrorHandlingAlert
//
//  Created by Richard Stockdale on 13/10/2020.
//

import UIKit
import Foundation

class ErrorHandlingAlert: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var responseTitleLabel: UILabel!
    @IBOutlet weak var responseMessageLabel: UILabel!
    @IBOutlet weak var suggestionsTextView: UITextView!
    @IBOutlet weak var closeAlertButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    // MARK: - Init and Set up
    private func setViews() {
        containerView.layer.cornerRadius = 4;
        containerView.clipsToBounds = true;
        
        cancelButton.layer.cornerRadius = 4;
        cancelButton.clipsToBounds = true;
        
        suggestionsTextView.layer.cornerRadius = 4;
        suggestionsTextView.clipsToBounds = true;
        suggestionsTextView.layer.borderWidth = 1.0
        suggestionsTextView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    public func tearDown() {
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        rootView = Bundle.main.loadNibNamed("ErrorHandlingAlert", owner: self, options: nil)![0] as? UIView
        rootView?.frame = bounds
        addSubview(rootView!)
        setViews()
    }
    
    func updateUI(title:String, message: String, suggestions:[String]) {
        responseTitleLabel.text = title
        responseMessageLabel.text = message
        responseTitleLabel.text = title
        suggestionsTextView.font = FontManager.medium(size: 20.0)
        
        let fullAttributedString = NSMutableAttributedString()
        for suggestion: String in suggestions {
            let attributesDictionary:[NSAttributedString.Key:Any] = [NSAttributedString.Key.font : FontManager.infoText,NSAttributedString.Key.foregroundColor : UIColor.black]
            let bulletPoint: String = "\u{2022}"
            let attributedString = NSMutableAttributedString(string: bulletPoint, attributes: attributesDictionary)
            attributedString.append(NSAttributedString(string: " \(suggestion) \n"))
            let indent:CGFloat = 20
            let paragraphStyle = createParagraphAttribute(tabStopLocation: indent, defaultTabInterval: indent, firstLineHeadIndent: indent - 10, headIndent: indent)
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            fullAttributedString.append(attributedString)
        }
        suggestionsTextView.attributedText = fullAttributedString
    }
    
    func createParagraphAttribute(tabStopLocation:CGFloat, defaultTabInterval:CGFloat, firstLineHeadIndent:CGFloat, headIndent:CGFloat) -> NSParagraphStyle {
            let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            let options:[NSTextTab.OptionKey:Any] = [:]
            paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: tabStopLocation, options: options)]
            paragraphStyle.defaultTabInterval = defaultTabInterval
            paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
            paragraphStyle.headIndent = headIndent
            return paragraphStyle
        }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        tearDown()
    }
    
    @IBAction func closeAlertBtnTapped(_ sender: Any) {
        tearDown()
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        rootView = Bundle.main.loadNibNamed("ErrorHandlingAlert", owner: self, options: nil)![0] as? UIView
        rootView?.frame = bounds
        addSubview(rootView!)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

