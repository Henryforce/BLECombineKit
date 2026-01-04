//
//  BLEService.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
@preconcurrency import CoreBluetooth
import Foundation

/// A wrapper around `CBService` that provides Combine-based APIs.
public struct BLEService: Sendable {
  /// The underlying CoreBluetooth service.
  public let value: CBService
  private let peripheral: BLEPeripheral

  public init(value: CBService, peripheral: BLEPeripheral) {
    self.value = value
    self.peripheral = peripheral
  }

  /// Discovers characteristics for the service.
  /// - Parameter characteristicUUIDs: Optional list of characteristic UUIDs to discover.
  /// - Returns: A Publisher that emits discovered characteristics or an error.
  public func discoverCharacteristics(
    characteristicUUIDs: [CBUUID]?
  ) -> AnyPublisher<BLECharacteristic, BLEError> {
    return peripheral.discoverCharacteristics(characteristicUUIDs: characteristicUUIDs, for: value)
  }
}
