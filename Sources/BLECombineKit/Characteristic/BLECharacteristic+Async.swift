//
//  BLECharacteristic+Async.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 21/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

@available(iOS 15, macOS 12.0, *)
extension BLECharacteristic {
  /// Reads the value for the characteristic asynchronously.
  /// - Returns: The read data.
  public func readValueAsync() async throws -> BLEData {
    var iterator = readValue().values.makeAsyncIterator()
    guard let value = try await iterator.next() else {
      throw BLEError.unknown
    }
    return value
  }

  /// Returns an async stream for observing value updates of the characteristic.
  /// - Returns: An `AsyncThrowingStream` emitting data updates.
  public func observeValueStream() -> AsyncThrowingStream<BLEData, Error> {
    return observeValue().asyncThrowingStream
  }

  /// Sets notifications and returns an async stream for observing value updates of the characteristic.
  /// - Returns: An `AsyncThrowingStream` emitting data updates.
  public func observeValueUpdateAndSetNotificationStream() -> AsyncThrowingStream<BLEData, Error> {
    return observeValueUpdateAndSetNotification().asyncThrowingStream
  }
}
