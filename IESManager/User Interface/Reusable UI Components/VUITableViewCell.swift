//
//  VUITableViewCell.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/7/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

protocol VUITableCellDataSource {
    func setupcell(cellModel: VUITableCellModelProtocol)
}

class VUITableViewCell: UITableViewCell, VUITableCellDataSource {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupcell(cellModel: VUITableCellModelProtocol) {
        let cellModel = cellModel as! VUITableCellModel
        if let imageName = cellModel.icon {
            self.imageView?.image = UIImage(named: imageName)
            if cellModel.roundedIcon {
                roundedStyle(imageView!)
            }
        }
        self.textLabel?.text = cellModel.title
        self.textLabel?.accessibilityLabel = cellModel.title
        self.textLabel?.isAccessibilityElement = true
        self.textLabel?.font = FontManager.bodyText
        self.detailTextLabel?.text = cellModel.subtitle
        self.detailTextLabel?.textColor = .darkGray
        self.detailTextLabel?.font = FontManager.regular(size: 12)
        if cellModel.isActionEnabled {
            self.accessoryType = .disclosureIndicator
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.image = nil
        self.textLabel?.text = nil
        self.detailTextLabel?.text = nil
    }
}

class VUILargeIconTableCell: VUITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.bounds = CGRect(x: 0, y: 0, width: 45, height: 45)
        self.imageView?.contentMode = .scaleAspectFit
    }
}
