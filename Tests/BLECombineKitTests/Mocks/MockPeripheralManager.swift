//
//  MockCBPeripheralManager.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 27/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import BLECombineKit
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

final class MockBLECentral: BLECentral {
  var associatedCentral: CBCentral?

  var identifier = UUID()

  var maximumUpdateValueLength: Int = 0
}

final class MockBLEATTRequest: BLEATTRequest {
  var associatedRequest: CBATTRequest?

  var centralWrapper: BLECentral = MockBLECentral()

  var mutableCharacteristic = CBMutableCharacteristic(
    type: CBUUID(string: "0x00FF"),
    properties: .read,
    value: nil,
    permissions: .readable
  )
  var characteristic: CBCharacteristic {
    mutableCharacteristic
  }

  var offset: Int = 0

  var value: Data?

}
