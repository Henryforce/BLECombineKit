//
//  BLEPeripheralResult.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation

protocol BLEPeripheralResult {
    associatedtype BLEResultType
    
    var value: BLEResultType { get }
    
    init(value: BLEResultType, peripheral: BLEPeripheral)
}
