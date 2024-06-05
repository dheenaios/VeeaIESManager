//
//  Observable.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/9/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

class Observable<T> {
    var data: T {
        didSet {
            DispatchQueue.main.async { [weak self] in
                if let value = self?.data {
                    self?.observer?(value)
                }
            }
        }
    }
    var observer: ((T) -> Void)?
    
    init(_ data: T) {
        self.data = data
    }
}
