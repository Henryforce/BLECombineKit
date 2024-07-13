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
    var manager: CBCentralManager? { get }
    var isScanning: Bool { get }
    
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper]
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralWrapper]
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?)
    func stopScan()
    func connect(_ peripheral: CBPeripheralWrapper, options: [String : Any]?)
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper)
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?)
}

final class StandardCBCentralManagerWrapper: CBCentralManagerWrapper {
    
    var manager: CBCentralManager? {
        wrappedManager
    }
    
    var isScanning: Bool {
        wrappedManager.isScanning
    }
    
    let wrappedManager: CBCentralManager
    
    init(with manager: CBCentralManager) {
        self.wrappedManager = manager
    }
    
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper] {
        wrappedManager
            .retrievePeripherals(withIdentifiers: identifiers)
            .map { StandardCBPeripheralWrapper(peripheral: $0) }
    }
    
    func retrieveConnectedPeripherals(
      withServices serviceUUIDs: [CBUUID]
    ) -> [CBPeripheralWrapper] {
        wrappedManager
            .retrieveConnectedPeripherals(withServices: serviceUUIDs)
            .map { StandardCBPeripheralWrapper(peripheral: $0) }
    }
    
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {
        wrappedManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
    }
    
    func stopScan() {
        wrappedManager.stopScan()
    }
    
    func connect(_ peripheral: CBPeripheralWrapper, options: [String : Any]?) {
        wrappedManager.connect(peripheral.peripheral, options: options)
    }
    
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) {
        wrappedManager.cancelPeripheralConnection(peripheral.peripheral)
    }
    
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        wrappedManager.registerForConnectionEvents(options: options)
    }
    
    func setupDelegate(_ delegate: CBCentralManagerDelegate) {
        wrappedManager.delegate = delegate
    }
    
}
