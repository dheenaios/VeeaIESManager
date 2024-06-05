//
//  NotificationSendRecord.swift
//  IESManager
//
//  Created by Richard Stockdale on 08/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

// We need to be certain that the backend has been updated with the new token
struct NotificationSendRecord: Codable {
    let userId: String
    let fbToken: String
    let lastSend: Date
    let sendMethod: String
    let success: Bool

    var data: Data? {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            return encoded
        }

        return nil
    }

    static func loadFrom(data: Data) -> NotificationSendRecord? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(NotificationSendRecord.self, from: data) {
            return decoded
        }

        return nil
    }
}
