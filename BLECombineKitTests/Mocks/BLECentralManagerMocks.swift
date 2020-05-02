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

final class BLECentralManagerMock: BLECentralManagerProtocol {
    var scanForPeripheralsWasCalled = false
    func scanForPeripherals(withServices services: [CBUUID]?, options: [String : Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
        scanForPeripheralsWasCalled = true
        
        let peripheral = CBPeripheralWrapperMock()
        let blePeripheral = BLEPeripheral(peripheral: peripheral, centralManager: nil)
        return Just
            .init(blePeripheral)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    var connectWasCalled = false
    public func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?) {
        connectWasCalled = true
    }
}

final class CBCentralManagerMock: CBCentralManagerWrapper {
    var manager: CBCentralManager?
    
    var isScanning: Bool = false
    
    var retrievePeripheralsWasCalled = false
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] {
        retrievePeripheralsWasCalled = true
        return []
    }
    
    var retrieveConnectedPeripheralsWasCalled = false
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral] {
        retrieveConnectedPeripheralsWasCalled = true
        return []
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
    
    var cancelPeripheralConnection = false
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) {
        cancelPeripheralConnection = true
    }
    
    var registerForConnectionEvents = false
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        registerForConnectionEvents = true
    }
    
}
