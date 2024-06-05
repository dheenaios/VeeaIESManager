import Foundation

struct KeyValueRowData {
    let id = UUID()
    let key: String
    let value: String
}

class AboutVeeaHubViewModel {

    internal init(masModel: MasApiIntermediaryDataModel, hubInfo: HubInfo?) {
        self.masModel = masModel
        self.hubInfo = hubInfo
    }

    let unknown = "Unknown".localized()

    let masModel: MasApiIntermediaryDataModel
    let hubInfo: HubInfo?

    let navBarTitle = "About this VeeaHub"

    let deviceInfoSection = "Device Information"
    let networkSection = "Network"
    let otherSection = "Other"

    var deviceInfoSectionRows: [KeyValueRowData] {
        return [KeyValueRowData(key: "Model", value: modelName),
                KeyValueRowData(key: "Serial", value: serial ?? unknown),
                KeyValueRowData(key: "Software Version", value: softwareVersion)]
    }

    var networkSectionRows: [KeyValueRowData] {
        return [
            KeyValueRowData(key: "MAC Address", value: macAddress),
            KeyValueRowData(key: "IP Address", value: ipAddr),
            KeyValueRowData(key: "Connectivity", value: selectedGateway),
        ]
    }

    var otherSectionRows: [KeyValueRowData] {
        return [
            KeyValueRowData(key: "Node Type", value: nodeType),
            KeyValueRowData(key: "Timezone", value: timeZone)]

    }

    // MARK: - Device info
    private var serial: String? {
        guard let serial = masModel.iesInfo?.unit_serial_number else {
            return nil
        }

        return serial
    }

    private var modelName: String {
        guard let serial = serial else {
            return unknown
        }

        let model = VeeaHubHardwareModel.init(serial: serial)
        return model.description
    }

    private var softwareVersion: String {
        guard let v = masModel.iesInfo?.sw_version else { return unknown }
        return v
    }

    // MARK: - Network Row
    private var macAddress: String {
        guard let v = masModel.iesInfo?.node_mac else { return unknown }
        return v
    }

    private var ipAddr: String {
        return masModel.nodeStatus?.ethernet_ipv4_addr ?? unknown
    }

    private var selectedGateway: String {
        return masModel.nodeStatus?.border_gateway_selected ?? unknown
    }

    // MARK: - Other
    private var nodeType: String {
        guard let type = masModel.nodeConfig?.node_type else {
            return unknown
        }

        if type == "MEN" {
            return "Gateway (\(type))"
        }

        return type
    }

    private var timeZone: String {
        guard let config = masModel.locationConfig else {
            return unknown
        }

        let city = config.configuredLocation.city.replacingOccurrences(of: "_", with: " ")
        return "\(city), \(config.configuredLocation.countryCode)"
    }
}

