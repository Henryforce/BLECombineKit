//
//  BLECharacteristic.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
@preconcurrency import CoreBluetooth

/// A wrapper around `CBCharacteristic` that provides Combine-based APIs.
public struct BLECharacteristic: Sendable {
  /// The underlying CoreBluetooth characteristic.
  public let value: CBCharacteristic
  private let peripheral: BLEPeripheral

  public init(value: CBCharacteristic, peripheral: BLEPeripheral) {
    self.value = value
    self.peripheral = peripheral
  }

  /// Reads the value of the characteristic.
  /// - Returns: A Publisher that emits the value or an error.
  public func readValue() -> AnyPublisher<BLEData, BLEError> {
    peripheral.readValue(for: value)
  }

  /// Observes value updates for the characteristic.
  /// - Returns: A Publisher that emits the value whenever it updates.
  public func observeValue() -> AnyPublisher<BLEData, BLEError> {
    peripheral.observeValue(for: value)
  }

  /// Observes value updates and sets the notification/indication status.
  /// - Returns: A Publisher that emits the value whenever it updates.
  public func observeValueUpdateAndSetNotification() -> AnyPublisher<BLEData, BLEError> {
    peripheral.observeValueUpdateAndSetNotification(for: value)
  }

  /// Sets the notification/indication status for the characteristic.
  /// - Parameter enabled: Whether to enable or disable notifications.
  public func setNotifyValue(_ enabled: Bool) {
    peripheral.setNotifyValue(enabled, for: value)
  }

  /// Writes a value to the characteristic.
  /// - Parameters:
  ///   - data: The data to write.
  ///   - type: The type of write (with or without response).
  /// - Returns: A Publisher that completes on success or fails with an error.
  public func writeValue(
    _ data: Data,
    type: CBCharacteristicWriteType
  ) -> AnyPublisher<Never, BLEError> {
    return peripheral.writeValue(data, for: self.value, type: type)
  }
}
