//
//  CBManagerWrapper.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol CBCentralManagerWrapper {
    var isScanning: Bool { get }
    
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral]
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral]
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?)
    func stopScan()
    func connect(_ peripheral: CBPeripheral, options: [String : Any]?)
    func cancelPeripheralConnection(_ peripheral: CBPeripheral)
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?)
}

final class CBManagerWrapperImpl: CBCentralManagerWrapper {
    
    var isScanning: Bool {
        manager.isScanning
    }
    
    let manager: CBCentralManager
    
    init(with manager: CBCentralManager) {
        self.manager = manager
    }
    
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] {
        manager.retrievePeripherals(withIdentifiers: identifiers)
    }
    
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral] {
        manager.retrieveConnectedPeripherals(withServices: serviceUUIDs)
    }
    
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {
        manager.scanForPeripherals(withServices: serviceUUIDs, options: options)
    }
    
    func stopScan() {
        manager.stopScan()
    }
    
    func connect(_ peripheral: CBPeripheral, options: [String : Any]?) {
        manager.connect(peripheral, options: options)
    }
    
    func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        manager.cancelPeripheralConnection(peripheral)
    }
    
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        manager.registerForConnectionEvents(options: options)
    }
    
}
