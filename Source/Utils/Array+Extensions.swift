//
//  Array+Extensions.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 6/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation

extension Array {
    @inlinable var isNotEmpty: Bool {
        !isEmpty
    }
    
    func element(at index: Int) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }
}
