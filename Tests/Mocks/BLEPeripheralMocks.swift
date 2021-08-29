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
@testable import BLECombineKit

final class MockBLEPeripheral: BLEPeripheral, BLEPeripheralState {
    
    let connectionState = CurrentValueSubject<Bool, Never>(false)
    var peripheral: CBPeripheralWrapper
    
    init() {
        self.peripheral = MockCBPeripheralWrapper()
    }
    
    public func observeConnectionState() -> AnyPublisher<Bool, Never> {
        return Just.init(true).eraseToAnyPublisher()
    }
    
    var connectWasCalled = false
    func connect(with options: [String : Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
        connectWasCalled = true
        let blePeripheral = StandardBLEPeripheral(peripheral: peripheral, centralManager: nil)
        return Just.init(blePeripheral)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var disconnectWasCalled = false
    func disconnect() -> AnyPublisher<Bool, BLEError> {
        disconnectWasCalled = true
        return Just.init(false).setFailureType(to: BLEError.self).eraseToAnyPublisher()
    }
    
    var discoverServiceWasCalled = false
    func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError> {
        discoverServiceWasCalled = true
        let cbService = CBMutableService.init(type: CBUUID.init(string: "0x0000"), primary: true)
        let service = BLEService(value: cbService, peripheral: self)
        return Just.init(service)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var discoverCharacteristicsWasCalled = false
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, BLEError> {
        discoverCharacteristicsWasCalled = true
        let cbCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        let characteristic = BLECharacteristic(value: cbCharacteristic, peripheral: self)
        return Just.init(characteristic)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var observeValueWasCalled = false
    func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        observeValueWasCalled = true
        let data = BLEData(value: Data(), peripheral: self)
        return Just.init(data)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var observeValueUpdateAndSetNotificationWasCalled = false
    func observeValueUpdateAndSetNotification(for characteristicUUID: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        observeValueUpdateAndSetNotificationWasCalled = true
        let data = BLEData(value: Data(), peripheral: self)
        return Just.init(data)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var setNotifyValueWasCalled = false
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        setNotifyValueWasCalled = true
    }
    
    var observeRSSIValueWasCalled = false
    func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
        observeRSSIValueWasCalled = true
        return Just.init(NSNumber.init(value: 0))
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var writeValueWasCalled = false
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) -> AnyPublisher<Never, BLEError> {
        writeValueWasCalled = true
        return Empty(completeImmediately: true).setFailureType(to: BLEError.self).eraseToAnyPublisher()
    }
    
}

final class MockCBPeripheralWrapper: CBPeripheralWrapper {
    
    var peripheral: CBPeripheral?
    
    var state = CBPeripheralState.connected
    
    var identifier = UUID.init()
    
    var name: String? = "MockedPeripheral"
    
    var mockedServices: [CBService]?
    var services: [CBService]? {
        return mockedServices
    }
    
    var readRSSIWasCalled = false
    func readRSSI() {
        readRSSIWasCalled = true
    }
    
    var discoverServicesWasCalled = false
    func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        discoverServicesWasCalled = true
    }
    
    func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) {
        
    }
    
    var discoverCharacteristicsWasCalled = false
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        discoverCharacteristicsWasCalled = true
    }
    
    var readValueForCharacteristicWasCalled = false
    func readValue(for characteristic: CBCharacteristic) {
        readValueForCharacteristicWasCalled = true
    }
    
    func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
        return 0
    }
    
    var writeValueForCharacteristicWasCalled = false
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        writeValueForCharacteristicWasCalled = true
    }
    
    var setNotifyValueWasCalled = false
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        setNotifyValueWasCalled = true
    }
    
    func discoverDescriptors(for characteristic: CBCharacteristic) {
        
    }
    
    var readValueForDescriptorWasCalled = false
    func readValue(for descriptor: CBDescriptor) {
        readValueForDescriptorWasCalled = true
    }
    
    var writeValueForDescriptorWasCalled = false
    func writeValue(_ data: Data, for descriptor: CBDescriptor) {
        writeValueForDescriptorWasCalled = true
    }
    
    func openL2CAPChannel(_ PSM: CBL2CAPPSM) {
        
    }
}
