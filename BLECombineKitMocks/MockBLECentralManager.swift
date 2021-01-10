//
//  BLECentralManagerMocks.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine
import BLECombineKit

public final class MockBLECentralManager: BLECentralManager {
    
    public var centralManager: CBCentralManagerWrapper = MockCBCentralManagerWrapper()
    
    public var isScanning: Bool = false
    
    public init() { }
    
    public var retrievePeripheralsWasCalledCount = 0
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheral, BLEError> {
        retrievePeripheralsWasCalledCount += 1
        return Just.init(MockBLEPeripheral())
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    public var retrieveConnectedPeripheralsWasCalledCount = 0
    public func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheral, BLEError> {
        retrieveConnectedPeripheralsWasCalledCount += 1
        return Just.init(MockBLEPeripheral())
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    public var scanForPeripheralsWasCalledCount = 0
    public func scanForPeripherals(withServices services: [CBUUID]?, options: [String : Any]?) -> AnyPublisher<BLEScanResult, BLEError> {
        scanForPeripheralsWasCalledCount += 1
        
        let blePeripheral = MockBLEPeripheral()
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
    
    public var stopScanWasCalledCount = 0
    public func stopScan() {
        stopScanWasCalledCount += 1
    }
    
    public var connectWasCalledCount = 0
    public func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?) {
        connectWasCalledCount += 1
    }
    
    public var cancelPeripheralConnectionWasCalledCount = 0
    public func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) -> AnyPublisher<Bool, BLEError> {
        cancelPeripheralConnectionWasCalledCount += 1
        
        return Just.init(false).setFailureType(to: BLEError.self).eraseToAnyPublisher()
    }
    
    public var registerForConnectionEventsWasCalledCount = 0
    public func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        registerForConnectionEventsWasCalledCount += 1
    }
    
    public var observeWillRestoreStateWasCalledCount = 0
    public var observeWillRestoreStateDictionary = [String: Any]()
    public func observeWillRestoreState() -> AnyPublisher<[String: Any], Never> {
        observeWillRestoreStateWasCalledCount += 1
        return Just(observeWillRestoreStateDictionary).eraseToAnyPublisher()
    }
    
    public var observeDidUpdateANCSAuthorizationWasCalledCount = 0
    public var observeDidUpdateANCSAuthorizationPeripheral = MockBLEPeripheral()
    public func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never> {
        observeDidUpdateANCSAuthorizationWasCalledCount += 1
        return Just(observeDidUpdateANCSAuthorizationPeripheral).eraseToAnyPublisher()
    }
    
}
