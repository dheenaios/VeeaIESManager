import SwiftUI
import SharedBackendNetworking

struct CallLogsView: View {
    private static let requestText = "Requests"
    private static let requestResponseText = "Request/Response"

    @State private var isLogging = NetworkCallLogger.recordCalls
    @State private var selection = CallLogsView.requestResponseText
    private var options = [CallLogsView.requestResponseText, CallLogsView.requestText]
    private var requests: [NetworkCallLoggerItem] {
        NetworkCallLogger.shared.reversedRequests
    }
    private var results: [NetworkCallLoggerItem] {
        NetworkCallLogger.shared.reversedResults
    }
    @EnvironmentObject var host: HostWrapper

    var body: some View {
        VStack{
            HStack() {
                Toggle("Log Network Activity (toggle to clear)", isOn: $isLogging)
                    .onChange(of: isLogging) { newValue in
                        NetworkCallLogger.recordCalls = newValue
                    }
            }
            .padding()

            if isLogging {
                Picker("Filter logs", selection: $selection) {
                    ForEach(options, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                List {
                    if selection == "Requests" {
                        ForEach(requests, id: \.self) { rowProps in
                            NavigationLink(destination: CallRecordView(loggerItem: rowProps)) {
                                EntryRowView(props: rowProps)
                            }
                        }
                    }
                    else {
                        ForEach(results, id: \.self) { rowProps in
                            NavigationLink(destination: CallRecordView(loggerItem: rowProps)) {
                                EntryRowView(props: rowProps)
                            }
                        }
                    }
                }
            }
            else {
                Text("Logs are stored in memory, so if you kill the app, they will be wiped. Export before you kill the app")
                    .font(.caption)
            }

            Spacer()
        }
    }

    private func getLogs() -> String {
        let items = selection == CallLogsView.requestResponseText ? results : requests

        let title = "# Network Logs Export\n\n"

        let header = selection == CallLogsView.requestResponseText ? "## Results \n\n" : "## Requests \n\n"

        var results = String()
        for item in items {
            let t = item.logText
            results.append("\n\n---\n\n" + t)
        }

        let report = title + header + results
        return report
    }

    private func actionSheet() {
        guard let vc = host.controller else {
            return
        }

        let shareText = getLogs()

        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = vc.view // so that iPads won't crash

        vc.present(activityViewController,
                   animated: true,
                   completion: nil)
    }
}
