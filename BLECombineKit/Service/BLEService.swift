//
//  BLEService.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

public struct BLEService: BLEPeripheralResult {
    public let value: CBService
    public let peripheral: BLEMainPeripheralProtocol
    
    public init(value: CBService, peripheral: BLEMainPeripheralProtocol) {
       self.value = value
       self.peripheral = peripheral
    }
    
    public func discoverCharacteristics(characteristicUUIDs: [CBUUID]?) -> AnyPublisher<BLECharacteristic, BLEError> {
        return peripheral.discoverCharacteristics(characteristicUUIDs: characteristicUUIDs, for: value)
    }
}
