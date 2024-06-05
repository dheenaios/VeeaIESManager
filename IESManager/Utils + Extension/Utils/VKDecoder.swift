//
//  VKCoder.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/24/19.
//  Copyright © 2019 Veea. All rights reserved.
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
        } catch _ {
            //VKLog(e.localizedDescription)
            return nil
        }
    }
    
    static func serializeData(obj: Any?) -> Data? {
        if obj == nil {
            //VKLog("VKDecoder failed to serialize : Empty Data)")
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: obj!, options: .prettyPrinted)
            return data
        } catch _ {
            //VKLog("VKDecoder failed to serialize : \(e.localizedDescription)")
            return nil
        }
    }
}
