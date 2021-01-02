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
    private let peripheral: BLEPeripheralProtocol
    
    public init(value: CBCharacteristic, peripheral: BLEPeripheralProtocol) {
       self.value = value
       self.peripheral = peripheral
    }
    
    public func observeValue() -> AnyPublisher<BLEData, BLEError> {
        peripheral.observeValue(for: value)
    }
    
    public func observeValueUpdateAndSetNotification() -> AnyPublisher<BLEData, BLEError> {
        peripheral.observeValueUpdateAndSetNotification(for: value)
    }
    
    public func setNotifyValue(_ enabled: Bool) {
        peripheral.setNotifyValue(enabled, for: value)
    }
}
