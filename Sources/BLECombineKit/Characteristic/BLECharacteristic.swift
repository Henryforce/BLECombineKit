//
//  BLECharacteristic.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

public struct BLECharacteristic: BLEPeripheralResult {
  public let value: CBCharacteristic
  private let peripheral: BLEPeripheral

  public init(value: CBCharacteristic, peripheral: BLEPeripheral) {
    self.value = value
    self.peripheral = peripheral
  }

  public func readValue() -> AnyPublisher<BLEData, BLEError> {
    peripheral.readValue(for: value)
  }

  public func observeValue() -> AnyPublisher<BLEData, BLEError> {
    peripheral.observeValue(for: value)
  }

  public func observeValueUpdateAndSetNotification() -> AnyPublisher<BLEData, BLEError> {
    peripheral.observeValueUpdateAndSetNotification(for: value)
  }

  public func setNotifyValue(_ enabled: Bool) {
    peripheral.setNotifyValue(enabled, for: value)
  }

  public func writeValue(
    _ data: Data,
    type: CBCharacteristicWriteType
  ) -> AnyPublisher<Never, BLEError> {
    return peripheral.writeValue(data, for: self.value, type: type)
  }
}
