//
//  MockCBPeripheralManager.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 27/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import BLECombineKit
@preconcurrency import CoreBluetooth
import Foundation

final class MockCBPeripheralManager: CBPeripheralManager, @unchecked Sendable {
  struct UpdateValueStackValue: Equatable {
    let value: Data
    let characteristic: CBMutableCharacteristic
    let centrals: [CBCentral]?
  }

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

  var updateValueReturnStatus = false
  var updateValueStack = [UpdateValueStackValue]()
  override func updateValue(
    _ value: Data,
    for characteristic: CBMutableCharacteristic,
    onSubscribedCentrals centrals: [CBCentral]?
  ) -> Bool {
    let stackValue = UpdateValueStackValue(
      value: value,
      characteristic: characteristic,
      centrals: centrals
    )
    updateValueStack.append(stackValue)
    return updateValueReturnStatus
  }
}

final class MockBLECentral: BLECentral, @unchecked Sendable {
  var associatedCentral: CBCentral?

  var identifier = UUID()

  var maximumUpdateValueLength: Int = 0
}

final class MockBLEATTRequest: BLEATTRequest, @unchecked Sendable {
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
