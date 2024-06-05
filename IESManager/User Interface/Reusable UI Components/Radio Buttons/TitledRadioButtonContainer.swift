//
//  TitledContainer.swift
//  RadioButtons
//
//  Created by Richard Stockdale on 28/03/2022.
//

import Foundation
import UIKit

protocol TitledRadioButtonContainerDelegage: AnyObject {
    func didSelectItemAt(index: Int, in radioButtonContainer: TitledRadioButtonContainer)
}

class TitledRadioButtonContainer: LoadedXibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var labelBackground: UIView!
    
    weak var delegate: TitledRadioButtonContainerDelegage?
    
    var selectedIndex: Int? {
        get {
            for radioButton in radioButtons {
                if radioButton.button.isSelected {
                    return indexOf(button: radioButton)
                }
            }
            
            return nil
        }
        set {
            for (index, radioButton) in radioButtons.enumerated() {
                if index == newValue {
                    radioButton.select = true
                }
                else {
                    radioButton.select = false
                }
            }
        }
    }
    
    private var radioButtons = [RadioButtonView]()
    
    func setStackViewAxis(axis: NSLayoutConstraint.Axis) {
        stackView.axis = axis
        stackView.distribution = axis == .horizontal ? .fillEqually : .fill
    }
    
    func setTitles(_ titles: [String]) {
        radioButtons = [RadioButtonView]()
        
        for title in titles {
            let radio = RadioButtonView()
            radio.delegate = self
            radio.titleLabel.text = title
            radioButtons.append(radio)
            stackView.addArrangedSubview(radio)
        }
    }
    
    override func loaded() {        
        backgroundView.backgroundColor = .clear
        backgroundView.layer.borderColor = UIColor.secondaryLabel.cgColor
        labelBackground.backgroundColor = .systemBackground
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.cornerRadius = 7
        backgroundView.clipsToBounds = translatesAutoresizingMaskIntoConstraints
    }
    
    private func indexOf(button: RadioButtonView) -> Int? {
        for (index, radioButton) in radioButtons.enumerated() {
            if button === radioButton {
                return index
            }
        }
        
        return nil
    }
    
    override func setTheme() {
        super.setTheme()
        titleLabel.font = FontManager.regular(size: 14)
    }
}

extension TitledRadioButtonContainer: RadioButtonViewDelegate {
    func didSelect(radioButtonView: RadioButtonView) {
        for radioButton in radioButtons {
            if radioButton === radioButtonView {
                radioButton.select = true
            }
            else {
                radioButton.select = false
            }
        }
        
        if let index = indexOf(button: radioButtonView) {
            delegate?.didSelectItemAt(index: index, in: self)
        }
    }
}
