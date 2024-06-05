import SwiftUI

struct AboutVeeaHubView: View {
    let vm: AboutVeeaHubViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            SimpleHeaderView(title: vm.navBarTitle)
            AboutListView(vm: vm)
        }
    }
}

struct AboutListView: View {
    @EnvironmentObject var host: HostWrapper
    let vm: AboutVeeaHubViewModel

    var body: some View {
        List{
            Section(header: Text(vm.deviceInfoSection)) {
                ForEach(vm.deviceInfoSectionRows, id: \.id) { item in
                    KeyValueRowView(key: item.key, value: item.value)
                }
            }
            Section(header: Text(vm.networkSection)) {
                ForEach(vm.networkSectionRows, id: \.id) { item in
                    KeyValueRowView(key: item.key, value: item.value)
                }
            }
            Section(header: Text(vm.otherSection)) {
                ForEach(vm.otherSectionRows, id: \.id) { item in
                    KeyValueRowView(key: item.key, value: item.value)
                }
            }

            ActionButton(title: "Done", bgColor: InterfaceManager.shared.cm.themeTint) {
                host.controller?.dismiss(animated: true)
            }
            .listRowBackground(Color.clear)

        }
        .environment(\.defaultMinListRowHeight, 10)
    }
}
