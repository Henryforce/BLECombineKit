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
  var blePeripheral: BLETrackedPeripheral?

  func provide(
    for peripheral: CBPeripheralWrapper,
    centralManager: BLECentralManager
  ) -> BLETrackedPeripheral {
    buildBLEPeripheralWasCalledCount += 1
    return blePeripheral ?? MockBLEPeripheral()
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
    let peripheral = blePeripherals.element(at: buildBLEPeripheralWasCalledCount)
    buildBLEPeripheralWasCalledCount += 1
    return peripheral ?? MockBLEPeripheral()
  }
}
