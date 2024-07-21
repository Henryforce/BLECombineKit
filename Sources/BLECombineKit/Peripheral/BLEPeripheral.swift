//
//  BLEPeripheral.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

/// Interface definining the Bluetooth Peripheral that provides Combine APIs.
public protocol BLEPeripheral {
  /// Reference to the actual Bluetooth peripheral, via a wrapper.
  var associatedPeripheral: CBPeripheralWrapper { get }

  /// Observe the connection state of the peripheral.
  func observeConnectionState() -> AnyPublisher<Bool, Never>

  /// Connect to the peripheral with a given set of options.
  /// This method will return an event with a successful connection or an error.
  /// See the CBPeripheral's `connect(with:)`method for more information.
  func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError>

  /// Disconnect from the peripheral.
  /// This method will return an event with a successful connection or an error.
  @discardableResult func disconnect() -> AnyPublisher<Never, BLEError>

  /// Observe any changes to the name of the peripheral.
  /// An event will be triggered on any change to the peripheral's name, if any.
  /// See the `peripheralDidUpdateName` method on the CBPeripheralDelegate.
  func observeNameValue() -> AnyPublisher<String, Never>

  /// Observe any updates to the RSSI value of the peripheral.
  /// An event will be triggered on any change to the peripheral's rssi or if an error is triggered.
  /// See the `didReadRSSI:` method on the CBPeripheralDelegate.
  func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError>

  /// This method wraps up on top of CBPeripheral's `discoverServices`, which will then publish
  /// an event for each service discovered. This publisher will complete when all services are
  /// published or until an error is triggered.
  func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError>

  /// This method wraps up on top of CBPeripheral's `discoverCharacteristics`, which will then
  /// publish an event for characteristic discovered. This publisher will complete when all
  /// characteristics are published or until an error is triggered.
  func discoverCharacteristics(
    characteristicUUIDs: [CBUUID]?,
    for service: CBService
  ) -> AnyPublisher<BLECharacteristic, BLEError>

  /// Read the value of a given characteristic.
  /// This method will trigger a single event after the CBPeripheral calls the
  /// `didUpdateValueFor:` delegate method (see CBPeripheralDelegate) and it will then complete.
  func readValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>

  /// Start observing for a value updated on a given characteristic.
  /// An event is triggered every time the CBPeripheral calls the
  /// `didUpdateValueFor:` delegate method (see CBPeripheralDelegate).
  func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>

  /// Start observing for a value updated on a given characteristic and set the notify value on
  /// the peripheral (internally calls `setNotifyValue`).
  /// An event is triggered every time the CBPeripheral calls the
  /// `didUpdateValueFor:` delegate method (see CBPeripheralDelegate).
  func observeValueUpdateAndSetNotification(
    for characteristic: CBCharacteristic
  ) -> AnyPublisher<BLEData, BLEError>

  /// Set the notify on the peripheral for a given characteristic..
  func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic)

  /// Write a value, as Data, to a given characteristic.
  /// This method returns an empty event on success or an error.
  func writeValue(
    _ data: Data,
    for characteristic: CBCharacteristic,
    type: CBCharacteristicWriteType
  ) -> AnyPublisher<Never, BLEError>
}

/// Internal interface for tracking peripherals that exposes a state, which extends BLEPeripheral.
protocol BLETrackedPeripheral: BLEPeripheral {
  var connectionState: CurrentValueSubject<Bool, Never> { get }
}
