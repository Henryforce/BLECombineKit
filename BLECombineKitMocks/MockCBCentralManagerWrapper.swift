//
//  File.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 2/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
@testable import BLECombineKit

public final class MockCBCentralManagerWrapper: CBCentralManagerWrapper {
    public var manager: CBCentralManager?
    
    public var isScanning: Bool = false
    
    public init() { }
    
    public var retrievePeripheralsWasCalledCount = 0
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper] {
        retrievePeripheralsWasCalledCount += 1
        return [MockCBPeripheralWrapper()]
    }
    
    public var retrieveConnectedPeripheralsWasCalledCount = 0
    public func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralWrapper] {
        retrieveConnectedPeripheralsWasCalledCount += 1
        return [MockCBPeripheralWrapper()]
    }
    
    public var scanForPeripheralsWasCalledCount = 0
    public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {
        scanForPeripheralsWasCalledCount += 1
    }
    
    public var stopScanWasCalledCount = 0
    public func stopScan() {
        stopScanWasCalledCount += 1
    }
    
    public var connectWasCalledCount = 0
    public func connect(_ peripheral: CBPeripheralWrapper, options: [String : Any]?) {
        connectWasCalledCount += 1
    }
    
    public var cancelPeripheralConnectionWasCalledCount = 0
    public func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) {
        cancelPeripheralConnectionWasCalledCount += 1
    }
    
    public var registerForConnectionEventsWasCalledCount = 0
    public func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        registerForConnectionEventsWasCalledCount += 1
    }
    
}
