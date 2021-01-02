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

final class MockCBCentralManagerWrapper: CBCentralManagerWrapper {
    var manager: CBCentralManager?
    
    var isScanning: Bool = false
    
    var retrievePeripheralsWasCalledCount = 0
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper] {
        retrievePeripheralsWasCalledCount += 1
        return [MockCBPeripheralWrapper()]
    }
    
    var retrieveConnectedPeripheralsWasCalledCount = 0
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralWrapper] {
        retrieveConnectedPeripheralsWasCalledCount += 1
        return [MockCBPeripheralWrapper()]
    }
    
    var scanForPeripheralsWasCalledCount = 0
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {
        scanForPeripheralsWasCalledCount += 1
    }
    
    var stopScanWasCalledCount = 0
    func stopScan() {
        stopScanWasCalledCount += 1
    }
    
    var connectWasCalledCount = 0
    func connect(_ peripheral: CBPeripheralWrapper, options: [String : Any]?) {
        connectWasCalledCount += 1
    }
    
    var cancelPeripheralConnectionWasCalledCount = 0
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) {
        cancelPeripheralConnectionWasCalledCount += 1
    }
    
    var registerForConnectionEventsWasCalledCount = 0
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        registerForConnectionEventsWasCalledCount += 1
    }
    
}
