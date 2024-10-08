//
//  File.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 2/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import CoreBluetooth
import Foundation

@testable import BLECombineKit

final class MockCBCentralManagerWrapper: CBCentralManagerWrapper {
  var wrappedManager: CBCentralManager?

  var isScanning: Bool = false

  var delegate: CBCentralManagerDelegate?

  var setupDelegateWasCalledStack = [CBCentralManagerDelegate]()
  func setupDelegate(_ delegate: CBCentralManagerDelegate) {
    setupDelegateWasCalledStack.append(delegate)
  }

  var mockRetrieviePeripherals = [CBPeripheralWrapper]()
  var retrievePeripheralsWasCalledCount = 0
  func retrieveCBPeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper] {
    retrievePeripheralsWasCalledCount += 1
    return mockRetrieviePeripherals
  }

  var mockRetrieveConnectedPeripherals = [CBPeripheralWrapper]()
  var retrieveConnectedPeripheralsWasCalledCount = 0
  func retrieveConnectedCBPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralWrapper]
  {
    retrieveConnectedPeripheralsWasCalledCount += 1
    return mockRetrieveConnectedPeripherals
  }

  var scanForPeripheralsWasCalledCount = 0
  func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?) {
    scanForPeripheralsWasCalledCount += 1
  }

  var stopScanWasCalledCount = 0
  func stopScan() {
    stopScanWasCalledCount += 1
  }

  var connectWasCalledCount = 0
  func connect(_ wrappedPeripheral: CBPeripheralWrapper, options: [String: Any]?) {
    connectWasCalledCount += 1
  }

  var cancelPeripheralConnectionWasCalledCount = 0
  func cancelPeripheralConnection(_ wrappedPeripheral: CBPeripheralWrapper) {
    cancelPeripheralConnectionWasCalledCount += 1
  }

  var registerForConnectionEventsWasCalledCount = 0
  func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?) {
    registerForConnectionEventsWasCalledCount += 1
  }

}
