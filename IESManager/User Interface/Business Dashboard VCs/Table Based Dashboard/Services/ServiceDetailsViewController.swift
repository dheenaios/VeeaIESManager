//
//  ServiceDetailsViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 17/12/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class ServiceDetailsViewController: UIViewController {

    var package: VHMeshNodePackage!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var featuresTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDetails()
    }
    
    private func setDetails() {
        titleLabel.text = package.displayTitle
        subTitleLabel.text = package.description
        priceLabel.text = package.type?.uppercased() ?? "Unknown"
    }
}

extension ServiceDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return package.features?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BulletItemCell
        let feature = package.features?[indexPath.row]

        cell.itemTextLabel.text = feature
        
        return cell
    }
}

class BulletItemCell: UITableViewCell {
    
    @IBOutlet weak var itemTextLabel: UILabel!
}
