//
//  BLEService.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

public struct BLEService: BLEPeripheralResult {
  public let value: CBService
  private let peripheral: BLEPeripheral

  public init(value: CBService, peripheral: BLEPeripheral) {
    self.value = value
    self.peripheral = peripheral
  }

  public func discoverCharacteristics(
    characteristicUUIDs: [CBUUID]?
  ) -> AnyPublisher<BLECharacteristic, BLEError> {
    return peripheral.discoverCharacteristics(characteristicUUIDs: characteristicUUIDs, for: value)
  }
}
