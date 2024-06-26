//
//  String+Base64.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 26/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
