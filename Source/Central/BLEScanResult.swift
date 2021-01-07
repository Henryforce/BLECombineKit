//
//  BLEScanResult.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation

public final class BLEScanResult {
    public let peripheral: BLEPeripheral
    public let advertisementData: [String: Any]
    public let rssi: NSNumber
    
    public init(peripheral: BLEPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
}
