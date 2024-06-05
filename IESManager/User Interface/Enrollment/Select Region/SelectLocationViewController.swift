//
//  SelectTimezoneViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 2/7/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

protocol LocationSelectorDelegate {
    func didSelectLocation(region: String, area: String, countryCode: String)
}

fileprivate enum LocationConfigType: Int {
    case country
    case timezone
}

class SelectLocationViewController: TabTableViewController {
    
    var timezonData: VUITableCellModel!
    var countryData: VUITableCellModel!
    fileprivate var currentconfigType: LocationConfigType = .timezone
    
    var delegate: LocationSelectorDelegate?
    
    convenience init(timezone: String, country: String) {
        self.init()
        
        countryData = VUITableCellModel()
        countryData.title = "Country".localized()
        countryData.subtitle = country
        
        timezonData = VUITableCellModel()
        timezonData.title = "Timezone".localized()
        timezonData.subtitle = timezone
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Timezone Settings".localized()
        self.removeBackButtonTitle()
        
        self.tableView.contentInset.top = UIConstants.Margin.top
        
        let titleString = "Select Timezone".localized()
        let detailString = "Select the country/timezone you would like to set for this VeeaHub. This location data will use used for configuring the timezone on your VeeaHub.".localized()
        
        let titleView = TitleWithSubtextView(title: titleString, subtext: detailString)
        titleView.addOffset(UIConstants.Margin.side * 2)
        self.tableView.tableHeaderView = titleView
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // continue button
        var continueButtonContainer = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        
        if traitCollection.userInterfaceStyle == .dark {
            continueButtonContainer = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        }
        
        continueButtonContainer.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: 70)
        continueButtonContainer.frame.size.height += UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
        let continueButton = VUIFlatButton(frame: CGRect(x: UIConstants.Margin.side, y: UIConstants.Margin.side, width: UIConstants.contentWidth, height: 40), type: .green, title: "Continue".localized())
        continueButton.addTarget(self, action: #selector(SelectLocationViewController.continueAction), for: .touchUpInside)
        continueButton.accessibility(config: AccessibilityConfigurations.buttonTimezoneContinue)
        continueButtonContainer.contentView.addSubview(continueButton)
        continueButtonContainer.frame.origin.y = self.view.bounds.height - self.navbarMaxY - continueButtonContainer.frame.height
        self.view.insertSubview(continueButtonContainer, aboveSubview: tableView)
    }
    
    @objc func continueAction() {
        do {
            let fileName = "Timezone_\(countryCodeFromString(str: countryData.subtitle!))"
            if let data = try Bundle.main.jsonData(fromFile: fileName, format: "json") {
                let json = try JSONDecoder().decode([String: String].self, from: data)
                let keys = (json as NSDictionary).allKeys(for: timezonData.subtitle!) as! [String]
                // America/North_Dakota/New_Salem
                let timezone = keys[0].split(separator: "/", maxSplits: 1)
                let timezoneArea = timezone.first ?? ""
                let timezoneRegion = timezone.last ?? ""
                self.delegate?.didSelectLocation(region:String(timezoneRegion), area: String(timezoneArea), countryCode: countryCodeFromString(str: countryData.subtitle!))
            }
        } catch {
            fatalError("could not get country code")
        }
    }

    private func countryCodeFromString(str: String) -> String {
        // Get the first two characters. This is the country code
        return String(str.prefix(2))
    }
    
    // MARK: - Helpers
    func loadCountries() -> [String] {
        var values: [String] = []
            do {
                if let data = try Bundle.main.jsonData(fromFile: "Countries", format: "json") {
                    let json = try JSONDecoder().decode([String].self, from: data)
                    values = json
                }
            } catch {
                fatalError("Could not read from file)")
            }
        
        return values.sorted()
    }
    
    func getTimezones(for country: String) -> [String] {
        do {
            let countryCode = countryCodeFromString(str: country)
            let fileName = "Timezone_\(countryCode)"
            if let data = try Bundle.main.jsonData(fromFile: fileName, format: "json") {
                let json = try JSONDecoder().decode([String: String].self, from: data)
                return Array(json.values).sorted()
            }
        } catch {
            fatalError("could not get country code")
        }
        
        return []
    }
}

// MARK: - UITableViewDataSource
extension SelectLocationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VUITableViewCell.self)) as? VUITableViewCell
        
        if cell == nil {
            cell = VUITableViewCell.init(style: .value1, reuseIdentifier: String(describing: VUITableViewCell.self))
        }
        
        switch indexPath.row {
        case 0:
            cell?.setupcell(cellModel: countryData)
        case 1:
            cell?.setupcell(cellModel: timezonData)
        default:
            break
        }
        return cell!
    }
}

// MARK: - UITableViewDelegate
extension SelectLocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.currentconfigType = LocationConfigType(rawValue: indexPath.row)!
        var data: [String] = []
        var titleString: String = timezonData.title
        
        if currentconfigType == .country {
            data = self.loadCountries()
            titleString = countryData.title
        } else if currentconfigType == .timezone {
            data = self.getTimezones(for: countryCodeFromString(str: self.countryData.subtitle!))
        }
        
        let detailVC = LocationListViewController(data: data, title: titleString, delegate: self)
        self.show(detailVC, sender: self)
    }
}


// MARK: - TimezoneSettingSelectorDelegate
extension SelectLocationViewController: LocationSettingSelectorDelegate {
    func didSelect(value: String) {
        
        switch self.currentconfigType {
        case .timezone:
            self.timezonData.subtitle = value

        case .country:
            self.countryData.subtitle = value
            self.timezonData.subtitle = self.getTimezones(for: value).first ?? ""
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.tableView.reloadData()
        }
    }
}
