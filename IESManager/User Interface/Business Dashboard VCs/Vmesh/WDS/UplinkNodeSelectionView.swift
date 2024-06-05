//
//  UplinkNodeSelectionView.swift
//  UI_Playground
//
//  Created by Richard Stockdale on 14/10/2022.
//

import SwiftUI

struct UplinkNodeSelectionView: View {

    private var host: HostWrapper?
    @ObservedObject var vm = UplinkNodeSelectionViewModel()


    var body: some View {
        ZStack {
            List {
                WdsListRows.verticalKeyValueRow(key: "Auto".localized(),
                                                values: [String](),
                                                checkMark: vm.isSelectedBssid(nodeBssid: ""))
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.selectedBssid = ""
                }

                if vm.lastReport == nil {
                    Section(header: Text("Scan in progress. Please wait...".localized())) {}
                }
                else {
                    Section(header: Text("Available Nodes".localized())) {
                        ForEach(vm.rows, id: \.self) { row in
                            WdsListRows.verticalKeyValueRow(key: row.name,
                                                            values: row.detailsText,
                                                            checkMark: vm.isSelectedBssid(nodeBssid: row.bssid))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                vm.selectedBssid = row.bssid
                            }
                        }
                    }

                    if let scanTime = vm.lastReportDate {
                        Text("Last Scan".localized() + ": \(scanTime)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .simpleListStyle()
            .frame(maxWidth: .infinity)
            .navBarTitle("Uplink Node")
            .navigationBarItems(trailing:
                                    HStack {
                Button("Refresh".localized()) {vm.startScan()}
                    .disabled(!vm.refreshButtonEnabled)
                Button("Apply".localized()) {
                    vm.showConfirmationAlert.toggle()
                }
                .disabled(vm.disableApplyButton)
            })
            .alert(isPresented: $vm.showErrorAlert) {
                Alert(
                    title: Text("Error".localized()),
                    message: Text(vm.lastSendError),
                    dismissButton: .cancel(Text("OK".localized()))
                )
            }

            if vm.sending {
                SendingView()
            }
        }
        .alert(isPresented: $vm.showConfirmationAlert) {
            Alert(title: Text("Change Uplink Node".localized()),
                  message: Text(vm.confirmText),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text("OK".localized()), action: {
                self.applyChanges()
            }))
        }
        .disabled(vm.sending)
        .onAppear {
            vm.startScanIfNonExisting()
        }
    }

    private func applyChanges() {
        vm.sending.toggle()
        vm.applyChanges {
            if let vc = self.meshViewController() {
                host?.controller?.navigationController?.popToViewController(vc, animated: true)
            }
            else {
                host?.controller?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    private func meshViewController() -> UIViewController? {
        guard let viewControllers = host?.controller?.navigationController?.viewControllers else {
            return nil
        }

        for vc in viewControllers {
            if vc.isKind(of: MeshDetailViewController.self) {
                return vc
            }
        }

        return nil
    }

    init(host: HostWrapper?) {
        self.host = host
    }
}

struct UplinkNodeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UplinkNodeSelectionView(host: nil)
    }
}

