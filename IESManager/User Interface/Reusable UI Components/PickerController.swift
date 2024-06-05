//
//  PickerController.swift
//  VeeaHub Manager
//
//  Created by Al on 10/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit

protocol PickerControllerDelegate {
    func didSelect(value: String, picker: UIPickerView)
}

class PickerController<ValueType>: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    var delegate: PickerControllerDelegate
    var picker: UIPickerView
    var values: [ValueType]
    
    var isShowing = false

    init(values: [ValueType], picker: UIPickerView, delegate: PickerControllerDelegate) {
        self.delegate = delegate
        self.values = values
        
        self.picker = picker
        
        super.init()
        
        self.picker.dataSource = self
        self.picker.delegate = self
    }
    
    func refresh(values: [ValueType]) {
        self.values = values
        picker.reloadComponent(0)
        self.pickerView(picker, didSelectRow: 0, inComponent: 0)
    }
    
    func toggle() -> Bool {
        isShowing = !isShowing
        
        picker.reloadComponent(0)
        
        return isShowing
    }
    
    func setPickerToIntValue(value: Int) {
        for (index, candidateValue) in values.enumerated() {
            let intVal = candidateValue as! Int
            
            if intVal == value {
                picker.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    
    func setPickerToStringValue(value: String) {
        for (index, candidateValue) in values.enumerated() {
            let intVal = candidateValue as! String
            
            if intVal == value {
                picker.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }

    //
    // MARK: - UIPickerViewDataSource
    //
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
    //
    // MARK: - UIPickerViewDelegate
    //
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(values[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        isShowing = false
        delegate.didSelect(value: "\(values[row])", picker: picker)
    }
}
