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

@available(iOS 13, macOS 12.0, *)
extension BLECentralManager {

  public func scanForPeripheralsStream(
    withServices services: [CBUUID]?,
    options: [String: Any]?
  ) async throws -> AsyncThrowingStream<BLEPeripheral, Error> {
    return AsyncThrowingStream { continuation in
      let cancellable = scanForPeripherals(withServices: services, options: options)
        .sink { completion in
          if case .failure(let error) = completion {
            continuation.finish(throwing: error)
          }
          else {
            continuation.finish()
          }
        } receiveValue: { scanResult in
          continuation.yield(scanResult.peripheral)
        }
      continuation.onTermination = { _ in
        cancellable.cancel()
      }
    }
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
