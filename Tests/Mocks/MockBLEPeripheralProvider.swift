//
//  MockBLEPeripheralBuilder.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation
@testable import BLECombineKit

final class MockBLEPeripheralProvider: BLEPeripheralProvider {
    var provideBLEPeripheralWasCalledCount = 0
    var blePeripheral: BLETrackedPeripheral?
    
    func provide(
        for peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager
    ) -> BLETrackedPeripheral {
        provideBLEPeripheralWasCalledCount += 1
        return blePeripheral ?? MockBLEPeripheral(peripheral: peripheral as! MockCBPeripheralWrapper)
    }
}

/// Internal only: Used for returning nil peripheral on multiple build calls
final class MockArrayBLEPeripheralBuilder: BLEPeripheralProvider {
    var buildBLEPeripheralWasCalledCount = 0
    var blePeripherals = [BLETrackedPeripheral]()
    
    func provide(
        for peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager
    ) -> BLETrackedPeripheral {
        let p = blePeripherals.element(at: buildBLEPeripheralWasCalledCount)
        buildBLEPeripheralWasCalledCount += 1
        return p ?? MockBLEPeripheral(peripheral: peripheral as! MockCBPeripheralWrapper)
    }
}
