//
//  BLEService+Async.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 21/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

@available(iOS 15, macOS 12.0, *)
extension BLEService {
  /// Discovers characteristics for the service asynchronously.
  /// - Parameter characteristicUUIDs: Optional list of characteristic UUIDs to discover.
  /// - Returns: An array of discovered characteristics.
  public func discoverCharacteristicsAsync(
    characteristicUUIDs: [CBUUID]?
  ) async throws -> [BLECharacteristic] {
    var iterator = discoverCharacteristics(characteristicUUIDs: characteristicUUIDs)
      .collect()
      .values
      .makeAsyncIterator()

    guard let results = try await iterator.next() else {
      throw BLEError.unknown
    }
    return results
  }
}
