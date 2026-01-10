//
//  MockPeripheralManagerSupportingTypes.swift
//  BLECombineKitMocks
//

import CoreBluetooth
import Foundation
import BLECombineKit

open class MockBLECentral: BLECentral, @unchecked Sendable {
    public init() { }
    public var associatedCentral: CBCentral?
    public var identifierValue: UUID = UUID()
    public var identifier: UUID {
        identifierValue
    }
    public var maximumUpdateValueLengthValue: Int = 0
    public var maximumUpdateValueLength: Int {
        maximumUpdateValueLengthValue
    }
}

open class MockBLEATTRequest: BLEATTRequest, @unchecked Sendable {
    public init() { }
    public var associatedRequest: CBATTRequest?
    public var centralWrapper: BLECentral = MockBLECentral()
    public var characteristic: CBCharacteristic = CBMutableCharacteristic(
        type: CBUUID(string: "0x00FF"),
        properties: .read,
        value: nil,
        permissions: .readable
    )
    public var offsetValue: Int = 0
    public var offset: Int {
        offsetValue
    }
    public var value: Data?
}
