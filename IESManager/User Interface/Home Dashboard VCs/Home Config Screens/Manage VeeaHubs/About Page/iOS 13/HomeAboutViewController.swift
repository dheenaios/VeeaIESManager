//
//  HomeAboutViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 10/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class HomeAboutViewController: HomeUserBaseViewController {

    private let height: CGFloat = 15
    private let fontSize: CGFloat = 12



    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var vm: AboutVeeaHubViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = vm.navBarTitle
    }

    static func new(vm: AboutVeeaHubViewModel) -> HomeAboutViewController {
        let vc = UIStoryboard(name: StoryboardNames.ManageVeeaHubs.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: "HomeAboutViewController") as! HomeAboutViewController
        vc.vm = vm

        return vc
    }

    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

}

extension HomeAboutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return vm.deviceInfoSection
        }
        if section == 1 {
            return vm.networkSection
        }

        return vm.otherSection
    }
}

extension HomeAboutViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return vm.deviceInfoSectionRows.count
        }
        if section == 1 {
            return vm.networkSectionRows.count
        }

        return vm.otherSectionRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath) as! KeyValueCell

        let section = indexPath.section
        var model: KeyValueRowData?
        if section == 0 {
            model = vm.deviceInfoSectionRows[indexPath.row]
        }
        if section == 1 {
            model = vm.networkSectionRows[indexPath.row]
        }
        if section == 2 {
            model = vm.otherSectionRows[indexPath.row]
        }

        cell.keyLabel.text = model?.key ?? "Unknown".localized()
        cell.keyLabel.font = UIFont.systemFont(ofSize: fontSize)
        cell.valueLabel.text = model?.value ?? "Unknown".localized()
        cell.valueLabel.font = UIFont.systemFont(ofSize: fontSize)

        return cell
    }
}
