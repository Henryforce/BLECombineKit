//
//  BLEPeripheralMocks.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import BLECombineKit
import Combine

final class BLEPeripheralMock: BLEMainPeripheralProtocol {
    var connectionState: CurrentValueSubject<Bool, Never>
    
    var peripheral: CBPeripheralWrapper
    
    init() {
        self.connectionState = CurrentValueSubject<Bool, Never>(false)
        self.peripheral = CBPeripheralWrapperMock()
    }
    
    var connectWasCalled = false
    func connect(with options: [String : Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
        connectWasCalled = true
        let blePeripheral = BLEPeripheral(peripheral: peripheral, centralManager: nil)
        return Just.init(blePeripheral)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
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
    
    var observeRSSIValueWasCalled = false
    func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
        observeRSSIValueWasCalled = true
        return Just.init(NSNumber.init(value: 0))
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    
}

final class CBPeripheralWrapperMock: CBPeripheralWrapper {
    
    var peripheral: CBPeripheral?
    
    var state = CBPeripheralState.connected
    
    var identifier = UUID.init()
    
    var name: String? = "MockedPeripheral"
    
    var services: [CBService]? {
        let mutableService = CBMutableService(type: CBUUID.init(), primary: true)
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        mutableService.characteristics = [mutableCharacteristic]
        return [mutableService]
    }
    
    func readRSSI() {
        
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
    
    func readValue(for characteristic: CBCharacteristic) {
        
    }
    
    func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
        return 0
    }
    
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        
    }
    
    var setNotifyValueWasCalled = false
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        setNotifyValueWasCalled = true
    }
    
    func discoverDescriptors(for characteristic: CBCharacteristic) {
        
    }
    
    func readValue(for descriptor: CBDescriptor) {
        
    }
    
    func writeValue(_ data: Data, for descriptor: CBDescriptor) {
        
    }
    
    func openL2CAPChannel(_ PSM: CBL2CAPPSM) {
        
    }
}
