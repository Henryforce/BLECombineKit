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
    var buildBLEPeripheralWasCalledCount = 0
    var blePeripheral: BLEPeripheral?
    func provide(
        for peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager
    ) -> BLEPeripheral? {
        buildBLEPeripheralWasCalledCount += 1
        return blePeripheral
    }
}

/// Internal only: Used for returning nil peripheral on multiple build calls
final class MockArrayBLEPeripheralBuilder: BLEPeripheralProvider {
    var buildBLEPeripheralWasCalledCount = 0
    var blePeripherals = [BLEPeripheral?]()
    func provide(
        for peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager
    ) -> BLEPeripheral? {
        let peripheral = blePeripherals.element(at: buildBLEPeripheralWasCalledCount)
        buildBLEPeripheralWasCalledCount += 1
        return peripheral ?? nil
    }
}
