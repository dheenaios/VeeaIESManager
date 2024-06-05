//
//  MultiPickerViewController.swift
//  MultiplePicker
//
//  Created by Richard Stockdale on 24/06/2018.
//  Copyright © 2018 JunctionSeven. All rights reserved.
//

import UIKit

class MultiPickerViewController: UIViewController {
    
    var completionBlock: (([PickerItem], Bool) -> Void)?
    var initialItems: [PickerItem]?
    var selectionItems: [PickerItem]?
    var changed = false
    
    @IBOutlet weak var tableView: UITableView!
    
    public func createMultiplePicker(named vcTitle: String,
                                     withItems items: [PickerItem],
                                     completion: @escaping (([PickerItem], Bool) -> Void)) {
        title = vcTitle
        completionBlock = completion
        initialItems = items
        selectionItems = items
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard selectionItems != nil && completionBlock != nil else {
            return
        }
        
        completionBlock!(selectionItems!, itemsHaveChanged())
    }
    
    private func itemsHaveChanged() -> Bool {
        guard let initial = initialItems, let update = selectionItems else {
            return false
        }
        
        let initialInts = PickerItem.pickerItemArrayToArrayOfSelectionInts(pickerItems: initial)
        let updateInts = PickerItem.pickerItemArrayToArrayOfSelectionInts(pickerItems: update)
        
        
        return !initialInts.containsSameElements(as: updateInts)
    }
}

extension MultiPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let items = selectionItems else {
            return;
        }
        
        let item = items[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = cell?.accessoryType == .checkmark ? .none : .checkmark
        
        selectionItems![indexPath.row] = PickerItem(title: item.itemTitle, isTicked: !item.itemIsTicked)
    }
}

extension MultiPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = selectionItems else {
            return 0
        }
        
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = selectionItems else {
            return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.itemTitle
        cell.accessoryType = item.itemIsTicked ? .checkmark : .none
        
        return cell
    }
}

struct PickerItem {
    var itemTitle: String
    var itemIsTicked: Bool
    
    init(title: String, isTicked: Bool) {
        itemTitle = title
        itemIsTicked = isTicked
    }
    
    static func pickerItemArrayToArrayOfSelectionInts(pickerItems: [PickerItem]) -> [Int] {
        var ints = [Int]()
        for pickerItem in pickerItems {
            if pickerItem.itemIsTicked {
                if let i = Int(pickerItem.itemTitle) {
                    ints.append(i)
                }
            }
        }
        
        return ints
    }
}
