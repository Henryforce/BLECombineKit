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
  public func readValueAsync(for characteristic: CBCharacteristic) async throws -> BLEData {
    var iterator = readValue().values.makeAsyncIterator()
    guard let value = try await iterator.next() else {
      throw BLEError.unknown
    }
    return value
  }

  public func observeValueStream(
    for characteristic: CBCharacteristic
  ) -> AsyncThrowingStream<BLEData, Error> {
    return observeValue().asyncThrowingStream
  }

  public func observeValueUpdateAndSetNotificationStream(
    for characteristic: CBCharacteristic
  ) -> AsyncThrowingStream<BLEData, Error> {
    return observeValueUpdateAndSetNotification().asyncThrowingStream
  }
}
