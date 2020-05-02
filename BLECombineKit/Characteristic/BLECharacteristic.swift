//
//  BLECharacteristic.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

public struct BLECharacteristic: BLEPeripheralResult {
    public let value: CBCharacteristic
    public let peripheral: BLEMainPeripheralProtocol
    
    public init(value: CBCharacteristic, peripheral: BLEMainPeripheralProtocol) {
       self.value = value
       self.peripheral = peripheral
    }
    
    public func observeValue() -> AnyPublisher<BLEData, BLEError> {
        return peripheral.observeValue(for: value)
    }
    
    public func observeValueUpdateAndSetNotification() -> AnyPublisher<BLEData, BLEError> {
        return peripheral.observeValueUpdateAndSetNotification(for: value)
    }
}
