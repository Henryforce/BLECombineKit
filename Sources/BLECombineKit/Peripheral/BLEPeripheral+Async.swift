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
    let stream = discoverServices(serviceUUIDs: serviceUUIDs).values
    return try await stream.reduce(into: []) { partialResult, service in
      partialResult.append(service)
    }
  }

  public func discoverCharacteristicsAsync(
    characteristicUUIDs: [CBUUID]?,
    for service: CBService
  ) async throws -> [BLECharacteristic] {
    let stream = discoverCharacteristics(characteristicUUIDs: characteristicUUIDs, for: service)
      .collect()
      .values
//    return try await stream.reduce(into: []) { partialResult, characteristic in
//      partialResult.append(characteristic)
//    }
//    var results = [BLECharacteristic]()
    for try await results in stream {
      return results
    }
//    return results
    return []
  }

  public func readValueAsync(for characteristic: CBCharacteristic) async throws -> BLEData {
    var iterator = readValue(for: characteristic).values.makeAsyncIterator()
    guard let value = try await iterator.next() else {
      throw BLEError.unknown
    }
    return value
  }
}
