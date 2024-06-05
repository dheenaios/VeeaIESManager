//
//  VKDecoder.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 16/06/2022.
//

import Foundation

struct VKDecoder {

    static func decode<T: Decodable>(type: T.Type, data: Data?) -> T? {
        do {
            guard data != nil else {
                return nil
            }

            //t BELOW IS JUST HERE TO HELP INSPECT RESPONSES.
            //let json = try? JSONSerialization.jsonObject(with: data!, options: [])

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            let toReturn = try decoder.decode(type, from: data!)
            return toReturn
        } catch {
            return nil
        }
    }

    static func serializeData(obj: Any?) -> Data? {
        if obj == nil {
            return nil
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: obj!, options: .prettyPrinted)
            return data
        } catch _ {
            return nil
        }
    }
}
