//
//  BLEScanResult.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation

public struct BLEScanResult {
    public let peripheral: BLEPeripheralProtocol
    public let advertisementData: [String: Any]
    public let rssi: NSNumber
    
    public init(peripheral: BLEPeripheralProtocol, advertisementData: [String: Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
}
