//
//  MockPeripheralManagerSupportingTypes.swift
//  BLECombineKitMocks
//

import BLECombineKit
import CoreBluetooth
import Foundation

/// A mock implementation of `BLECentral` for testing purposes.
open class MockBLECentral: BLECentral, @unchecked Sendable {
  public init() {}
  /// The associated `CBCentral`.
  public var associatedCentral: CBCentral?
  /// Flag to control the `identifier` property.
  public var identifierValue: UUID = UUID()
  public var identifier: UUID {
    identifierValue
  }
  /// Flag to control the `maximumUpdateValueLength` property.
  public var maximumUpdateValueLengthValue: Int = 0
  public var maximumUpdateValueLength: Int {
    maximumUpdateValueLengthValue
  }
}

/// A mock implementation of `BLEATTRequest` for testing purposes.
open class MockBLEATTRequest: BLEATTRequest, @unchecked Sendable {
  public init() {}
  /// The associated `CBATTRequest`.
  public var associatedRequest: CBATTRequest?
  /// The central wrapper.
  public var centralWrapper: BLECentral = MockBLECentral()
  /// The characteristic.
  public var characteristic: CBCharacteristic = CBMutableCharacteristic(
    type: CBUUID(string: "0x00FF"),
    properties: .read,
    value: nil,
    permissions: .readable
  )
  /// Flag to control the `offset` property.
  public var offsetValue: Int = 0
  public var offset: Int {
    offsetValue
  }
  /// The value of the request.
  public var value: Data?
}
