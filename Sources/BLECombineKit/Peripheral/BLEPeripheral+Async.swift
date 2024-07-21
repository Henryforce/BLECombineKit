//
//  BLEPeripheral+Async.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 19/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

@available(iOS 15, macOS 12.0, *)
extension BLEPeripheral {
  @discardableResult
  public func connectAsync(
    with options: [String: Any]?
  ) async throws -> BLEPeripheral {
    var iterator = connect(with: options)
      .values
      .makeAsyncIterator()

    guard let connectedPeripheral = try await iterator.next() else {
      throw BLEError.unknown
    }
    return connectedPeripheral
  }

  public func discoverServicesAsync(
    serviceUUIDs: [CBUUID]?
  ) async throws -> [BLEService] {
    var iterator = discoverServices(serviceUUIDs: serviceUUIDs)
      .collect()
      .values
      .makeAsyncIterator()

    guard let results = try await iterator.next() else {
      throw BLEError.unknown
    }
    return results
  }

  public func discoverCharacteristicsAsync(
    characteristicUUIDs: [CBUUID]?,
    for service: CBService
  ) async throws -> [BLECharacteristic] {
    var iterator = discoverCharacteristics(characteristicUUIDs: characteristicUUIDs, for: service)
      .collect()
      .values
      .makeAsyncIterator()

    guard let results = try await iterator.next() else {
      throw BLEError.unknown
    }
    return results
  }

  public func readValueAsync(for characteristic: CBCharacteristic) async throws -> BLEData {
    var iterator = readValue(for: characteristic).values.makeAsyncIterator()
    guard let value = try await iterator.next() else {
      throw BLEError.unknown
    }
    return value
  }

  public func observeValueStream(
    for characteristic: CBCharacteristic
  ) -> AsyncThrowingStream<BLEData, Error> {
    return observeValue(for: characteristic).asyncThrowingStream
  }

  public func observeValueUpdateAndSetNotificationStream(
    for characteristic: CBCharacteristic
  ) -> AsyncThrowingStream<BLEData, Error> {
    return observeValueUpdateAndSetNotification(for: characteristic).asyncThrowingStream
  }
}
