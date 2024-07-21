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
typealias DidDiscoverServicesResult = (peripheral: CBPeripheralWrapper, error: Error?)
typealias DidDiscoverCharacteristicsResult = (
  peripheral: CBPeripheralWrapper, service: CBService, error: Error?
)
typealias DidUpdateValueForCharacteristicResult = (
  peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: Error?
)
typealias DidDiscoverDescriptorForCharacteristicResult = (
  peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: Error?
)
typealias DidUpdateValueForDescriptorResult = (
  peripheral: CBPeripheralWrapper, descriptor: CBDescriptor, error: Error?
)
typealias DidReadRSSIResult = (peripheral: CBPeripheralWrapper, rssi: NSNumber, error: Error?)
typealias DidWriteValueForCharacteristicResult = (
  peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: Error?
)
typealias DidUpdateNotificationStateResult = (
  peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: BLEError?
)

final class BLEPeripheralDelegate: NSObject {

  /// Subject for the name update callback.
  let didUpdateName = PassthroughSubject<DidUpdateName, Never>()

  /// Subject used for the discover services callback.
  let didDiscoverServices = PassthroughSubject<DidDiscoverServicesResult, Error>()

  /// Subject used for the discover characteristics callback.
  let didDiscoverCharacteristics = PassthroughSubject<DidDiscoverCharacteristicsResult, Error>()

  /// Subject used for the discover descriptors callback.
  let didDiscoverDescriptors = PassthroughSubject<
    DidDiscoverDescriptorForCharacteristicResult, Error
  >()

  /// Subject used for the update value of a characteristic callback.
  let didUpdateValueForCharacteristic = PassthroughSubject<
    DidUpdateValueForCharacteristicResult, Error
  >()

  /// Subject used for the update value of a characteristic descriptor callback.
  let didUpdateValueForDescriptor = PassthroughSubject<DidUpdateValueForDescriptorResult, Error>()

  /// Subject used for the update value of the RSSI callback.
  let didReadRSSI = PassthroughSubject<DidReadRSSIResult, Error>()

  /// Subject used for the didWrite callback.
  let didWriteValueForCharacteristic = PassthroughSubject<
    DidWriteValueForCharacteristicResult, Error
  >()

  /// Subject used for the didUpdateNotificationState callback.
  let didUpdateNotificationState = PassthroughSubject<DidUpdateNotificationStateResult, BLEError>()

}

extension BLEPeripheralDelegate: CBPeripheralDelegate {
  func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    if let name = peripheral.name {
      didUpdateName.send((peripheral: peripheralWrapper, name: name))
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didDiscoverServices.send((peripheral: peripheralWrapper, error: error))
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverCharacteristicsFor service: CBService,
    error: Error?
  ) {
    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didDiscoverCharacteristics.send((peripheral: peripheralWrapper, service: service, error: error))
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverDescriptorsFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didDiscoverDescriptors.send(
      (peripheral: peripheralWrapper, characteristic: characteristic, error: error)
    )
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didUpdateValueForCharacteristic.send(
      (peripheral: peripheralWrapper, characteristic: characteristic, error: error)
    )
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor descriptor: CBDescriptor,
    error: Error?
  ) {
    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didUpdateValueForDescriptor.send(
      (peripheral: peripheralWrapper, descriptor: descriptor, error: error)
    )
  }

  func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didReadRSSI.send((peripheral: peripheralWrapper, rssi: RSSI, error: error))
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didWriteValueFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didWriteValueForCharacteristic.send(
      (peripheral: peripheralWrapper, characteristic: characteristic, error: error)
    )
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: (any Error)?
  ) {
    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    let bleError = bleError(from: error)
    didUpdateNotificationState.send(
      (peripheral: peripheralWrapper, characteristic: characteristic, error: bleError)
    )
  }

  private func bleError(from error: Error?) -> BLEError? {
    guard let validError = error as? NSError else { return nil }
    return BLEError.peripheral(
      .servicesFoundError(
        BLEError.CoreBluetoothError.from(error: validError)
      )
    )
  }
}
