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
  /// Connects to the peripheral asynchronously.
  /// - Parameter options: Optional connection options.
  /// - Returns: The connected peripheral.
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

  /// Discovers services for the peripheral asynchronously.
  /// - Parameter serviceUUIDs: Optional list of service UUIDs to discover.
  /// - Returns: An array of discovered services.
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

  /// Discovers characteristics for a specified service asynchronously.
  /// - Parameters:
  ///   - characteristicUUIDs: Optional list of characteristic UUIDs to discover.
  ///   - service: The service to discover characteristics for.
  /// - Returns: An array of discovered characteristics.
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

  /// Reads the value for a specific characteristic asynchronously.
  /// - Parameter characteristic: The characteristic to read from.
  /// - Returns: The read data.
  public func readValueAsync(for characteristic: CBCharacteristic) async throws -> BLEData {
    var iterator = readValue(for: characteristic).values.makeAsyncIterator()
    guard let value = try await iterator.next() else {
      throw BLEError.unknown
    }
    return value
  }

  /// Returns an async stream for observing value updates of a characteristic.
  /// - Parameter characteristic: The characteristic to observe.
  /// - Returns: An `AsyncThrowingStream` emitting data updates.
  public func observeValueStream(
    for characteristic: CBCharacteristic
  ) -> AsyncThrowingStream<BLEData, Error> {
    return observeValue(for: characteristic).asyncThrowingStream
  }

  /// Sets notifications and returns an async stream for observing value updates of a characteristic.
  /// - Parameter characteristic: The characteristic to observe.
  /// - Returns: An `AsyncThrowingStream` emitting data updates.
  public func observeValueUpdateAndSetNotificationStream(
    for characteristic: CBCharacteristic
  ) -> AsyncThrowingStream<BLEData, Error> {
    return observeValueUpdateAndSetNotification(for: characteristic).asyncThrowingStream
  }

  /// Writes data to a specific characteristic asynchronously.
  /// - Parameters:
  ///   - data: The data to write.
  ///   - characteristic: The characteristic to write to.
  ///   - type: The type of write operation.
  public func writeValueAsync(
    _ data: Data,
    for characteristic: CBCharacteristic,
    type: CBCharacteristicWriteType
  ) async throws {
    let stream = writeValue(data, for: characteristic, type: type).values
    for try await _ in stream { return }
  }
}
