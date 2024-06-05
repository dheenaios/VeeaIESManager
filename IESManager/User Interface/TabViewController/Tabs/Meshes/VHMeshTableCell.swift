//
//  VHMeshTableCell.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/9/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class VHMeshTableCell: UITableViewCell, VUITableCellDataSource {
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subTitle: UILabel!
    
    // MAARK: - VUITableCellDataSource
    func setupcell(cellModel: VUITableCellModelProtocol) {
        let model = cellModel as! MeshCellViewModel

        self.accessoryType = .disclosureIndicator

        self.accessibilityLabel = model.titleText
        self.title.text = model.titleText
        self.subTitle.text = model.detailText
        self.icon.image = UIImage(named: model.imageName)
    }
}


/*

 // Swift UI implementation of the above.
 See JIRA URL: https://max2inc.atlassian.net/browse/VHM-1651
 And MeshTableCell View

 //var content: UIView?

 func setupcell(cellModel: VUITableCellModelProtocol) {
    let model = cellModel as! MeshCellViewModel
    self.accessibilityLabel = model.titleText

    let meshView = MeshTableCellView(title: model.titleText,
                                    subtitle: model.detailText,
                                    imageName: model.imageName)

    if self.content != nil {
     self.content?.removeFromSuperview()
    }

    self.content = SwiftUIUIView<MeshTableCellView>(view: meshView,
                                                    requireSelfSizing: false).make()
    self.content?.addAndPinToEdgesOf(outerView: self.contentView)
}


 */
