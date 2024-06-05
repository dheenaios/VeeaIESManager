//
//  ConfirmEnrollmentSetttingsDataSource.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 2/5/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class ConfirmEnrollmentSettingsDataSource: NSObject, UITableViewDataSource {
    
    var enrollmentData: Enrollment! {
        didSet {
            self.loadTableData(from: enrollmentData)
        }
    }
    
    private var tableData: [VUITableCellModel] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VUITableViewCell.self)) as? VUITableViewCell
        if cell == nil {
            cell = VUITableViewCell(style: .value1, reuseIdentifier: String(describing: VUITableViewCell.self))
        }
        cell?.setupcell(cellModel: tableData[indexPath.row])
        return cell!
    }
    
    // MARK: - Helper
    private func loadTableData(from enrollment: Enrollment) {
        
        // Name
        var _name = VUITableCellModel()
        _name.title = "Name".localized()
        _name.subtitle = enrollment.name
        _name.isActionEnabled = false
        self.tableData.append(_name)
        
        // Model
        var _model = VUITableCellModel()
        _model.title = "Model".localized()
        _model.subtitle = enrollment.model
        _model.isActionEnabled = false
        self.tableData.append(_model)
        
        // Serial Number
        var _serialNo = VUITableCellModel()
        _serialNo.title = "Serial".localized()
        _serialNo.subtitle = enrollment.serialNumber
        _serialNo.isActionEnabled = false
         self.tableData.append(_serialNo)
        
        // Connection
        var _connection = VUITableCellModel()
        _connection.title = "Connection".localized()
        _connection.subtitle = enrollment.connection.type.stringValue
        _connection.isActionEnabled = false
         self.tableData.append(_connection)
        
        // Group
        if !enrollment.groupName.isEmpty {
            var _groupname = VUITableCellModel()
            _groupname.title = "Group".localized()
            _groupname.subtitle = enrollment.groupName
            _groupname.isActionEnabled = false
            self.tableData.append(_groupname)
        }
        
        // Mesh
        var _mesh = VUITableCellModel()
        _mesh.title = "Mesh".localized()
        _mesh.subtitle = enrollment.mesh.name
        _mesh.isActionEnabled = false
        self.tableData.append(_mesh)
        
        // Country
//        var _country = VUITableCellModel()
//        _country.title = "Country".localized()
//        _country.subtitle = enrollment.country ?? ""
//        _country.isActionEnabled = false
//        self.tableData.append(_country)

        // Area
//        var _area = VUITableCellModel()
//        _area.title = "Area".localized()
//        _area.subtitle = enrollment.timezoneArea ?? ""
//        _area.isActionEnabled = false
//        self.tableData.append(_area)
        
        // Region
//        var _region = VUITableCellModel()
//        _region.title = "Region".localized()
//        _region.subtitle = enrollment.timezoneRegion ?? ""//"\(enrollment.timezoneArea ?? "")/\(enrollment.timezoneRegion ?? "")"
//        _region.isActionEnabled = false
//        self.tableData.append(_region)
        
        var _region = VUITableCellModel()
        _region.title = "Locale".localized()
        _region.subtitle = "\(enrollment.timezoneArea ?? "")/\(enrollment.timezoneRegion ?? "")"
        _region.isActionEnabled = false
        self.tableData.append(_region)
        
        
        if let ssidStr = enrollment.ssid {
            if !ssidStr.isEmpty {
                var _ssid = VUITableCellModel()
                _ssid.title = "SSID".localized()
                _ssid.subtitle = enrollment.ssid
                _ssid.isActionEnabled = false
                self.tableData.append(_ssid)
            }
        }
    }
}
