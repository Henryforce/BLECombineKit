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
  ///
  /// - Returns: a Publisher that emits a boolean indicating a valid connection or not, which never completes.
  func observeConnectionState() -> AnyPublisher<Bool, Never>

  /// Connect to the peripheral with a given set of options.
  /// This method will return an event with a successful connection or an error.
  /// See the CBPeripheral's `connect(with:)`method for more information.
  ///
  /// - Returns: a Publisher that emits the connected peripheral and then completes or an error.
  func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError>

  /// Disconnect from the peripheral.
  ///
  /// - Returns: a Publisher that completes event with a successful connection or an error.
  @discardableResult func disconnect() -> AnyPublisher<Never, BLEError>

  /// Observe any changes to the name of the peripheral.
  /// See the CBPeripheralDelegate's `peripheralDidUpdateName(_:)`.
  ///
  /// - Returns: a Publisher that emits any change to the peripheral's name, which never completes.
  func observeNameValue() -> AnyPublisher<String, Never>

  /// Observe any updates to the RSSI value of the peripheral.
  /// See the CBPeripheralDelegate's `peripheral(_:didReadRSSI:error:)`.
  ///
  /// - Returns: a Publisher that emit the latest peripheral's rssi or an error.
  func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError>

  /// Discover all services given a collection of CBUUIDs.
  /// This method wraps up on top of CBPeripheralDelegate's
  /// `peripheral(_:didDiscoverServices:error:)`.
  ///
  /// - Returns: a Publisher that emits all the services available before completing or an error.
  func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError>

  /// Discover all characteristics on a service given a collection of CBUUIDs.
  /// This method wraps up on top of CBPeripheral's
  /// `peripheral(_:didDiscoverCharacteristicsFor:error:)`.
  ///
  /// - Returns: a Publisher that emits all the characteristics available before completing or an error.
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
  /// Note that this event does not update the notify/indicate status, if this status is not set
  /// then this method might never return any values. If you want to explicitly set the notify
  /// status, see `observeValueUpdateAndSetNotification(for:)`.
  func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>

  /// Start observing for a value updated on a given characteristic and set the notify value on
  /// the peripheral (internally calls `setNotifyValue`).
  /// An event is triggered every time the CBPeripheral calls the
  /// `didUpdateValueFor:` delegate method (see CBPeripheralDelegate).
  func observeValueUpdateAndSetNotification(
    for characteristic: CBCharacteristic
  ) -> AnyPublisher<BLEData, BLEError>

  /// Sets notifications or indications for the value of a specified characteristic.
  ///
  /// - Parameters:
  ///   - enabled: A Boolean value that indicates whether to receive notifications or indications whenever the characteristic’s value changes. true if you want to enable notifications or indications for the characteristic’s value. false if you don’t want to receive notifications or indications whenever the characteristic’s value changes.
  ///   - characteristic: The specified characteristic.
  func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic)

  /// Write a value, as Data, to a given characteristic.
  ///
  /// - Parameters:
  ///   - data: the data to write.
  ///   - characteristic: the characteristic to write to.
  ///   - type: the type of write to be performed (with or without response).
  ///
  /// - Returns: a Publisher that completes on success or an error.
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
