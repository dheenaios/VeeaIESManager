//
//  ShareLogger.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 01/07/2022.
//

import Foundation
import os.log

class Log {
    static func tag(tag: String, message: String) {
        SharedLogger.log(tag: tag, message: message)
    }
}

public class SharedLogger {
    public static let shared = SharedLogger()

    private let kSavedLogs = "kSavedLogs"
    private var saveTimer: Timer?
    private var unsavedLogs = false

    private var dateFormatter: DateFormatter
    private var sessionLog = [LogEntry]()

    public static func log(tag: String, message: String) {
        if !isQABuild {
            return
        }

        DispatchQueue.main.async {
            shared.logMessage(tag: tag, message: message)
        }
    }

    public func getSessionLogsWithTag(_ tag: String, reversed: Bool = true) -> String {
        if tag.isEmpty {
            return reversed ? getSessionLogReverse() : getSessionLog()
        }

        var logs = "# Session Logs:\nTAG:\(tag)\n\n"

        if reversed {
            for log in sessionLog {
                if log.tag.lowercased().contains(tag.lowercased())  {
                    let logString = dateFormatter.string(from: log.dateTime) + ": \n" + log.tag + ": " + log.message + "\n\n"
                    logs.append(logString)
                }
            }

            logs.append("\n  \nStart of Logs  \n...  \n...  \n...  \n...  \n")
        }
        else {
            for log in sessionLog.reversed() {
                if log.tag.lowercased().contains(tag.lowercased()) {
                    let logString = dateFormatter.string(from: log.dateTime) + ": \n" + log.tag + ": " + log.message + "\n\n"
                    logs.append(logString)
                }
            }

            logs.append("\n\n\n\n\n\n\n")
        }

        return logs
    }

    public func getSessionLog() -> String {
        var logs = "# Session Logs\n\n"

        for log in sessionLog {
            let logString = dateFormatter.string(from: log.dateTime) + ": \n" + log.tag + ": " + log.message + "\n\n"
            logs.append(logString)
        }

        logs.append("\n\n\n\n\n\n\n")

        return logs
    }

    public func getSessionLogReverse() -> String {
        var logs = "# Session Logs\n\n"

        for log in sessionLog.reversed() {
            let logString = dateFormatter.string(from: log.dateTime) + ": \n" + log.tag + ": " + log.message + "\n\n"
            logs.append(logString)
        }

        logs.append("\n  \nStart of Logs  \n...  \n...  \n...  \n...  \n")

        return logs
    }

    public func clearLogs() {
        sessionLog = [LogEntry]()
    }

    public func logMessage (tag: String, message: String) {

        // os_log takes care of logging performance.
        // logs for all release types wills show in console
        let logString = tag + ": " + message
        os_log(.default, "%{public}s", logString)

        // Only store logs for QA builds
        if !SharedLogger.isQABuild {
            return
        }

        let log = LogEntry(dateTime: Date(), tag: tag, message: message)
        sessionLog.append(log)
        unsavedLogs = true
    }

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long

        load()
    }

    private func load() {
        if !SharedLogger.isQABuild {
            return
        }

        let defaults = SharedUserDefaults.suite
        if let sessionData = defaults.object(forKey: kSavedLogs) as? Data {
            let decoder = JSONDecoder()
            if let session = try? decoder.decode([LogEntry].self, from: sessionData) {
                if session.count > 800 {
                    sessionLog = session.suffix(799)
                }
                else {
                    sessionLog = session
                }
            }
        }

        // Set the save timer
        saveTimer = Timer.scheduledTimer(timeInterval: 10.0,
                                         target: self,
                                         selector: #selector(save),
                                         userInfo: nil,
                                         repeats: true)
    }

    @objc private func save() {
        if !SharedLogger.isQABuild {
            return
        }

        if !unsavedLogs {
            return
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(sessionLog) {
            let defaults = SharedUserDefaults.suite
            defaults.set(encoded, forKey: kSavedLogs)
        }
        else {
            print("Error saving logs")
        }
    }

    private static var isQABuild: Bool {
        ApplicationTargets.current == .QA
    }
}

struct LogEntry: Codable {
    let dateTime: Date
    let tag: String
    let message: String

    init(dateTime: Date, tag: String, message: String) {
        self.dateTime = dateTime
        self.tag = tag
        self.message = message
    }

}

// MARK: - Decoding Errors
extension SharedLogger {
    public static func logDecodingError(className: String, tag: String, error: Error) {
        let message = "JSON \(className) decoding error: \(error)"
        SharedLogger.shared.logMessage(tag: tag, message: message)
    }
}
