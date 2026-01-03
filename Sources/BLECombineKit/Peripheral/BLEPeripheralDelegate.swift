//
//  BLEPeripheralDelegate.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

typealias DidUpdateName = (peripheral: CBPeripheralWrapper, name: String)
typealias DidDiscoverServicesResult = (peripheral: CBPeripheralWrapper, error: BLEError?)
typealias DidDiscoverCharacteristicsResult = (
  peripheral: CBPeripheralWrapper, service: CBService, error: BLEError?
)
typealias DidUpdateValueForCharacteristicResult = (
  peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: BLEError?
)
typealias DidDiscoverDescriptorForCharacteristicResult = (
  peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: BLEError?
)
typealias DidUpdateValueForDescriptorResult = (
  peripheral: CBPeripheralWrapper, descriptor: CBDescriptor, error: BLEError?
)
typealias DidReadRSSIResult = (peripheral: CBPeripheralWrapper, rssi: NSNumber, error: BLEError?)
typealias DidWriteValueForCharacteristicResult = (
  peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: BLEError?
)

final class BLEPeripheralDelegate: NSObject, @unchecked Sendable {

  /// Subject for the name update callback.
  let didUpdateName = PassthroughSubject<DidUpdateName, Never>()

  /// Subject used for the discover services callback.
  let didDiscoverServices = PassthroughSubject<DidDiscoverServicesResult, BLEError>()

  /// Subject used for the discover characteristics callback.
  let didDiscoverCharacteristics = PassthroughSubject<DidDiscoverCharacteristicsResult, BLEError>()

  /// Subject used for the discover descriptors callback.
  let didDiscoverDescriptors = PassthroughSubject<
    DidDiscoverDescriptorForCharacteristicResult, BLEError
  >()

  /// Subject used for the update value of a characteristic callback.
  let didUpdateValueForCharacteristic = PassthroughSubject<
    DidUpdateValueForCharacteristicResult, BLEError
  >()

  /// Subject used for the update value of a characteristic descriptor callback.
  let didUpdateValueForDescriptor = PassthroughSubject<
    DidUpdateValueForDescriptorResult, BLEError
  >()

  /// Subject used for the update value of the RSSI callback.
  let didReadRSSI = PassthroughSubject<DidReadRSSIResult, BLEError>()

  /// Subject used for the didWrite callback.
  let didWriteValueForCharacteristic = PassthroughSubject<
    DidWriteValueForCharacteristicResult, BLEError
  >()
}

extension BLEPeripheralDelegate: CBPeripheralDelegate {
  func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
    if let name = peripheral.name {
      didUpdateName.send((peripheral: peripheral, name: name))
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    let bleError = didDiscoverServicesError(from: error)
    didDiscoverServices.send((peripheral: peripheral, error: bleError))
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverCharacteristicsFor service: CBService,
    error: Error?
  ) {
    let bleError = didDiscoverCharacteristicsError(from: error)
    didDiscoverCharacteristics.send(
      (peripheral: peripheral, service: service, error: bleError)
    )
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverDescriptorsFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    let bleError = didDiscoverDescriptorsError(from: error)
    didDiscoverDescriptors.send(
      (peripheral: peripheral, characteristic: characteristic, error: bleError)
    )
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    let bleError = didUpdateValueForCharacteristicError(from: error)
    didUpdateValueForCharacteristic.send(
      (peripheral: peripheral, characteristic: characteristic, error: bleError)
    )
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor descriptor: CBDescriptor,
    error: Error?
  ) {
    let bleError = didUpdateValueForDescriptorError(from: error)
    didUpdateValueForDescriptor.send(
      (peripheral: peripheral, descriptor: descriptor, error: bleError)
    )
  }

  func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    let bleError = readRSSIError(from: error)
    didReadRSSI.send((peripheral: peripheral, rssi: RSSI, error: bleError))
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didWriteValueFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    let bleError = didWriteValueError(from: error)
    didWriteValueForCharacteristic.send(
      (peripheral: peripheral, characteristic: characteristic, error: bleError)
    )
  }

  // MARK - Private.

  private func didDiscoverDescriptorsError(from error: Error?) -> BLEError? {
    guard let error else { return nil }
    let coreBluetoothError = BLEError.CoreBluetoothError.from(error: error as NSError)
    return BLEError.peripheral(.didDiscoverDescriptorsError(coreBluetoothError))
  }

  private func didUpdateValueForCharacteristicError(from error: Error?) -> BLEError? {
    guard let error else { return nil }
    let coreBluetoothError = BLEError.CoreBluetoothError.from(error: error as NSError)
    return BLEError.peripheral(.didUpdateValueForCharacteristicError(coreBluetoothError))
  }

  private func didUpdateValueForDescriptorError(from error: Error?) -> BLEError? {
    guard let error else { return nil }
    let coreBluetoothError = BLEError.CoreBluetoothError.from(error: error as NSError)
    return BLEError.peripheral(.didUpdateValueForDescriptorError(coreBluetoothError))
  }

  private func didDiscoverServicesError(from error: Error?) -> BLEError? {
    guard let error else { return nil }
    let coreBluetoothError = BLEError.CoreBluetoothError.from(error: error as NSError)
    return BLEError.peripheral(.servicesFoundError(coreBluetoothError))
  }

  private func didDiscoverCharacteristicsError(from error: Error?) -> BLEError? {
    guard let error else { return nil }
    let coreBluetoothError = BLEError.CoreBluetoothError.from(error: error as NSError)
    return BLEError.peripheral(.characteristicsFoundError(coreBluetoothError))
  }

  private func readRSSIError(from error: Error?) -> BLEError? {
    guard let error else { return nil }
    let coreBluetoothError = BLEError.CoreBluetoothError.from(error: error as NSError)
    return BLEError.peripheral(.readRSSIError(coreBluetoothError))
  }

  private func didWriteValueError(from error: Error?) -> BLEError? {
    guard let error else { return nil }
    let coreBluetoothError = BLEError.CoreBluetoothError.from(error: error as NSError)
    return BLEError.peripheral(.writeError(coreBluetoothError))
  }
}
