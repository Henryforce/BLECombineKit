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
  public func discoverCharacteristicsAsync(
    characteristicUUIDs: [CBUUID]?,
    for service: CBService
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
