//
//  BLEData.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation

/// A wrapper around `Data` that provides convenient conversion methods for common types.
public struct BLEData: Sendable {
  /// The underlying raw data.
  public let value: Data

  public init(value: Data) {
    self.value = value
  }

  /// Converts the data to a 32-bit floating point value.
  public var floatValue: Float32? {
    self.to(type: Float32.self)
  }

  /// Converts the data to a 32-bit integer value.
  public var intValue: Int32? {
    self.to(type: Int32.self)
  }

  /// Converts the data to an unsigned 32-bit integer value.
  public var uintValue: UInt32? {
    self.to(type: UInt32.self)
  }

  /// Converts the data to a 16-bit integer value.
  public var int16Value: Int16? {
    self.to(type: Int16.self)
  }

  /// Converts the data to an unsigned 16-bit integer value.
  public var uint16Value: UInt16? {
    self.to(type: UInt16.self)
  }

  /// Converts the data to an 8-bit integer value.
  public var int8Value: Int8? {
    self.to(type: Int8.self)
  }

  /// Converts the data to an unsigned 8-bit integer value.
  public var uint8Value: UInt8? {
    self.to(type: UInt8.self)
  }

  /// Converts the raw data to a specified numeric type.
  /// - Parameter type: The type to convert to.
  /// - Returns: The converted value, or nil if the data size is insufficient.
  public func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
    var genericValue: T = 0
    guard value.count >= MemoryLayout.size(ofValue: genericValue) else { return nil }
    _ = Swift.withUnsafeMutableBytes(of: &genericValue, { value.copyBytes(to: $0) })
    return genericValue
  }
}
