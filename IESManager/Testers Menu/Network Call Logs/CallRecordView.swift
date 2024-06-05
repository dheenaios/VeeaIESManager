import SwiftUI
import SharedBackendNetworking

@available(iOS 14.0, *)
struct CallRecordView: View {

    let loggerItem: NetworkCallLoggerItem
    @EnvironmentObject var host: HostWrapper

    var body: some View {
        List {
            // If this is not a send then add an option to view the request
            if !loggerItem.send {
                Section(header: Text("Request")) {
                    let r = NetworkCallLoggerItem(request: loggerItem.result?.request, result: nil)
                    NavigationLink(destination: CallRecordView(loggerItem: r)) {
                        Text("View request")
                    }
                }
            }

            Section(header: Text("Sent Time")) {
                Text(DateFormatter.shortDateTime.string(from: loggerItem.created))
            }
            Section(header: Text("Request URL (Tap to copy)")) {
                Text(loggerItem.url)
                    .onTapGesture {
                        UIPasteboard.general.string = loggerItem.url
                    }
                    .font(.caption)
                Text("Method: \(loggerItem.httpMethod)")
                    .onTapGesture {
                        UIPasteboard.general.string = loggerItem.httpMethod
                    }
                if !loggerItem.send {
                    Text("HTTP Code: \(loggerItem.result?.httpCode ?? -1)")
                        .onTapGesture {
                            UIPasteboard.general.string = "\(loggerItem.result?.httpCode ?? -1)"
                        }
                }

            }

            if loggerItem.send {
                Section(header: Text("Headers (Tap cell to copy)")) {
                    ForEach(loggerItem.headers, id: \.self) { item in
                        Text(item)
                            .onTapGesture {
                                UIPasteboard.general.string = item
                            }
                    }
                }
            }

            Section(header: Text("Body (Tap to copy)")) {
                if loggerItem.send {
                    let body = loggerItem.request?.httpBody?.prettyPrintedString ?? ""
                    Text(body)
                        .onTapGesture {
                            UIPasteboard.general.string = body
                        }
                }
                else {
                    let body = loggerItem.result?.prettyPrintedData ?? ""
                    Text(body)
                        .onTapGesture {
                            UIPasteboard.general.string = body
                        }
                }
            }
        }
        .navigationTitle(loggerItem.send ? "Request" : "Response")
        .toolbar {
            if loggerItem.send {
                Button("Copy As CUrl") {
                    curlToPasteBoard()
                }
            }
        }
    }
    
    private func curlToPasteBoard() {
        let curl = loggerItem.request?.cURL(pretty: true)
        UIPasteboard.general.string = curl
    }
}
