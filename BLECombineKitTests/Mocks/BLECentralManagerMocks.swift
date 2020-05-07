//
//  BLECentralManagerMocks.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import BLECombineKit
import Combine

final class BLECentralManagerMock: BLECentralManager {
    
    var centralManager: CBCentralManagerWrapper = CBCentralManagerWrapperMock()
    
    var isScanning: Bool = false
    
    var retrievePeripheralsWasCalled = false
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheralProtocol, BLEError> {
        retrievePeripheralsWasCalled = true
        return Just.init(BLEPeripheralMock())
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var retrieveConnectedPeripheralsWasCalled = false
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheralProtocol, BLEError> {
        retrieveConnectedPeripheralsWasCalled = true
        return Just.init(BLEPeripheralMock())
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var scanForPeripheralsWasCalled = false
    func scanForPeripherals(withServices services: [CBUUID]?, options: [String : Any]?) -> AnyPublisher<BLEScanResult, BLEError> {
        scanForPeripheralsWasCalled = true
        
        let blePeripheral = BLEPeripheralMock()
        let advertisementData: [String: Any] = [:]
        let rssi = NSNumber.init(value: 0)
        
        let bleScanResult = BLEScanResult(peripheral: blePeripheral,
                                          advertisementData: advertisementData,
                                          rssi: rssi)
        
        return Just
            .init(bleScanResult)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var stopScanWasCalled = false
    func stopScan() {
        stopScanWasCalled = true
    }
    
    var connectWasCalled = false
    func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?) {
        connectWasCalled = true
    }
    
    var cancelPeripheralConnectionWasCalled = false
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) -> AnyPublisher<Bool, BLEError> {
        cancelPeripheralConnectionWasCalled = true
        
        return Just.init(false).setFailureType(to: BLEError.self).eraseToAnyPublisher()
    }
    
    var registerForConnectionEventsWasCalled = false
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        registerForConnectionEventsWasCalled = true
    }
    
}

final class CBCentralManagerWrapperMock: CBCentralManagerWrapper {
    var manager: CBCentralManager?
    
    var isScanning: Bool = false
    
    var retrievePeripheralsWasCalled = false
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper] {
        retrievePeripheralsWasCalled = true
        return [CBPeripheralWrapperMock()]
    }
    
    var retrieveConnectedPeripheralsWasCalled = false
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralWrapper] {
        retrieveConnectedPeripheralsWasCalled = true
        return [CBPeripheralWrapperMock()]
    }
    
    var scanForPeripheralsWasCalled = false
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {
        scanForPeripheralsWasCalled = true
    }
    
    var stopScanWasCalled = false
    func stopScan() {
        stopScanWasCalled = true
    }
    
    var connectWasCalled = false
    func connect(_ peripheral: CBPeripheralWrapper, options: [String : Any]?) {
        connectWasCalled = true
    }
    
    var cancelPeripheralConnectionWasCalled = false
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) {
        cancelPeripheralConnectionWasCalled = true
    }
    
    var registerForConnectionEventsWasCalled = false
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        registerForConnectionEventsWasCalled = true
    }
    
}
