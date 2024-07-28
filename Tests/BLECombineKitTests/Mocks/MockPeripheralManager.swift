//
//  MockCBPeripheralManager.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 27/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import CoreBluetooth

final class MockCBPeripheralManager: CBPeripheralManager {
  var mutableState = CBManagerState.unknown
  override var state: CBManagerState {
    mutableState
  }

  var addServiceStack = [CBMutableService]()
  override func add(_ service: CBMutableService) {
    addServiceStack.append(service)
  }

  var removeStack = [CBMutableService]()
  override func remove(_ service: CBMutableService) {
    removeStack.append(service)
  }

  var removeAllServicesCount = 0
  override func removeAllServices() {
    removeAllServicesCount += 1
  }
}
