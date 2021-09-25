//
//  BLEPeripheralMocks.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine
import BLECombineKit

public final class MockBLEPeripheral: BLEPeripheral, BLEPeripheralState {
    
    public let connectionState = CurrentValueSubject<Bool, Never>(false)
    public var peripheral: CBPeripheralWrapper
    
    public init() {
        self.peripheral = MockCBPeripheralWrapper()
    }
    
    public func observeConnectionState() -> AnyPublisher<Bool, Never> {
        return Just.init(true).eraseToAnyPublisher()
    }
    
    public var connectWasCalledCount = 0
    public func connect(with options: [String : Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
        connectWasCalledCount += 1
        let blePeripheral = StandardBLEPeripheral(peripheral: peripheral, centralManager: nil)
        return Just.init(blePeripheral)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    public var disconnectWasCalledCount = 0
    public func disconnect() -> AnyPublisher<Bool, BLEError> {
        disconnectWasCalledCount += 1
        return Just.init(false).setFailureType(to: BLEError.self).eraseToAnyPublisher()
    }
    
    public var discoverServiceWasCalledCount = 0
    public func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError> {
        discoverServiceWasCalledCount += 1
        let cbService = CBMutableService.init(type: CBUUID.init(string: "0x0000"), primary: true)
        let service = BLEService(value: cbService, peripheral: self)
        return Just.init(service)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    public var discoverCharacteristicsWasCalledCount = 0
    public func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, BLEError> {
        discoverCharacteristicsWasCalledCount += 1
        let cbCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        let characteristic = BLECharacteristic(value: cbCharacteristic, peripheral: self)
        return Just.init(characteristic)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    public var observeValueWasCalledCount = 0
    public func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        observeValueWasCalledCount += 1
        let data = BLEData(value: Data(), peripheral: self)
        return Just.init(data)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    public var observeValueUpdateAndSetNotificationWasCalledCount = 0
    public func observeValueUpdateAndSetNotification(for characteristicUUID: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        observeValueUpdateAndSetNotificationWasCalledCount += 1
        let data = BLEData(value: Data(), peripheral: self)
        return Just.init(data)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    public var setNotifyValueWasCalledCount = 0
    public func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        setNotifyValueWasCalledCount += 1
    }
    
    public var observeRSSIValueWasCalledCount = 0
    public func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
        observeRSSIValueWasCalledCount += 1
        return Just.init(NSNumber.init(value: 0))
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    public var writeValueWasCalledCount = 0
    public func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) -> AnyPublisher<Bool, BLEError> {
        writeValueWasCalledCount += 1
        return Just.init(true).setFailureType(to: BLEError.self).eraseToAnyPublisher()
    }
    
}
