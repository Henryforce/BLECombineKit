//
//  CBPeripheralWrapper.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import CoreBluetooth
import Foundation

extension CBPeripheral: CBPeripheralWrapper {
  public func setupDelegate(_ delegate: CBPeripheralDelegate) {
    self.delegate = delegate
  }

  public func connect(manager: CBCentralManager) {
    manager.connect(self)
  }

  public func cancelConnection(manager: CBCentralManager) {
    manager.cancelPeripheralConnection(self)
  }
}

public protocol CBPeripheralWrapper {
  /// The state of the wrapped CBPeripheral.
  var state: CBPeripheralState { get }

  /// The unique identifier of the wrapped CBPeripheral.
  var identifier: UUID { get }

  /// The name of the wrapped CBPeripheral, if any.
  var name: String? { get }

  /// The services of the wrapped CBPeripheral, if any.
  var services: [CBService]? { get }

  /// Set up the delegate of the wrapped CBPeripheral.
  /// Avoid calling this method unless you explicitly want to listen to delegate events at the cost
  /// of breaking the peripheral observable events.
  func setupDelegate(_ delegate: CBPeripheralDelegate)

  /// Connect to a CBCentralManager.
  func connect(manager: CBCentralManager)

  /// Cancel connection to a CBCentralManager.
  func cancelConnection(manager: CBCentralManager)

  /// Read the RSSI of the wrapped CBPeripheral.
  func readRSSI()

  /// Discover services of the wrapped CBPeripheral.
  func discoverServices(_ serviceUUIDs: [CBUUID]?)

  /// Discover included services of the wrapped CBPeripheral.
  func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService)

  /// Discover characteristics of the wrapped CBPeripheral.
  func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService)

  /// Read value of a given characteristic of the wrapped CBPeripheral.
  func readValue(for characteristic: CBCharacteristic)

  /// Get the maximum write value length of a write type of the wrapped CBPeripheral.
  func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int

  /// Write data for a given characteristic of the wrapped CBPeripheral.
  func writeValue(
    _ data: Data,
    for characteristic: CBCharacteristic,
    type: CBCharacteristicWriteType
  )

  /// Enable/Disable the notification status of a characteristic of the wrapped CBPeripheral.
  func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic)

  ///  Discover descriptors for a charactersitic of the wrapped CBPeripheral.
  func discoverDescriptors(for characteristic: CBCharacteristic)

  /// Read the value for a descriptor of the wrapped CBPeripheral.
  func readValue(for descriptor: CBDescriptor)

  /// Write value for a descriptor of the wrapped CBPeripheral.
  func writeValue(_ data: Data, for descriptor: CBDescriptor)

  /// Open an L2CAP channel of the wrapped CBPeripheral.
  func openL2CAPChannel(_ PSM: CBL2CAPPSM)
}
