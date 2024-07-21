//
//  BLECentralManager+Async.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 19/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

@available(iOS 15, macOS 12.0, *)
extension BLECentralManager {

  public func scanForPeripheralsStream(
    withServices services: [CBUUID]?,
    options: [String: Any]?
  ) -> AsyncThrowingStream<BLEPeripheral, Error> {
    let scanPublisher = scanForPeripherals(withServices: services, options: options)
      .map { $0.peripheral }
      .eraseToAnyPublisher()
    return scanPublisher.asyncThrowingStream
  }

  public func connectAsync(
    peripheral: BLEPeripheral,
    options: [String: Any]?
  ) async throws -> BLEPeripheral {
    var iterator = connect(peripheral: peripheral, options: options)
      .values
      .makeAsyncIterator()

    guard let connectedPeripheral = try await iterator.next() else {
      throw BLEError.unknown
    }
    return connectedPeripheral
  }
}
