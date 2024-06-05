//
//  HomeCellularStatsTableViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 22/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class HomeCellularUsageViewController: HomeUserBaseViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .home_cell_data_usage_screen

    let vm = HomeCellularUsageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    override func setTheme() {
        super.setTheme()
        self.view.backgroundColor = cm.background2.colorForAppearance
    }
}

extension HomeCellularUsageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        vm.timePeriods[section].title
    }
}

extension HomeCellularUsageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        vm.timePeriods.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UsageCell
        let model = vm.timePeriods[indexPath.section]
        cell.configure(config: model)
        
        return cell
    }
}

class UsageCell: UITableViewCell {
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    
    func configure(config: HomeCellularUsageViewModel.UsagePeriodDetails) {
        sentLabel.text = config.sent
        receivedLabel.text = config.received
    }
}

class HomeCellularUsageViewModel: HomeUserBaseViewModel {
    struct UsagePeriodDetails {
        let title: String
        let sentBytes: UInt64
        let receivedBytes: UInt64
        
        var sent: String {
            let converter = DataUnitConverter(bytes: Int64(sentBytes))
            return converter.getReadableUnit()
        }
        var received: String {
            let converter = DataUnitConverter(bytes: Int64(receivedBytes))
            return converter.getReadableUnit()
        }
    }
    
    let timePeriods: [UsagePeriodDetails]
        
    override init() {
        let config = HubDataModel.shared.optionalAppDetails!.cellularDataStatsConfig!
        
        let today = UsagePeriodDetails(title: "Today",
                                       sentBytes: config.bytes_sent_current_day,
                                       receivedBytes: config.bytes_recv_current_day)
        let yesterday = UsagePeriodDetails(title: "Yesterday",
                                           sentBytes: config.bytes_sent_previous_day,
                                           receivedBytes: config.bytes_recv_previous_day)
        let thisMonth = UsagePeriodDetails(title: "This Month",
                                           sentBytes: config.bytes_sent_current_month,
                                           receivedBytes: config.bytes_recv_current_month)
        let lastMonth = UsagePeriodDetails(title: "Last Month",
                                           sentBytes: config.bytes_sent_previous_month,
                                           receivedBytes: config.bytes_recv_previous_month)
        
        timePeriods = [today, yesterday, thisMonth, lastMonth]
    }
}
