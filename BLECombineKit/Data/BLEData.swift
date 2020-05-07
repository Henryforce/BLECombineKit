//
//  BLEData.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation

public struct BLEData: BLEPeripheralResult {
    public let value: Data
    public let peripheral: BLEPeripheralProtocol
    
    public init(value: Data, peripheral: BLEPeripheralProtocol) {
        self.value = value
        self.peripheral = peripheral
    }
    
    public var floatValue: Float32? {
        self.to(type: Float32.self)
    }
    
    public var intValue: Int32? {
        self.to(type: Int32.self)
    }
    
    public var uintValue: UInt32? {
        self.to(type: UInt32.self)
    }
    
    public var int16Value: Int16? {
        self.to(type: Int16.self)
    }
    
    public var uint16Value: UInt16? {
        self.to(type: UInt16.self)
    }
    
    public var int8Value: Int8? {
        self.to(type: Int8.self)
    }
    
    public var uint8Value: UInt8? {
        self.to(type: UInt8.self)
    }
    
    public func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var genericValue: T = 0
        guard value.count >= MemoryLayout.size(ofValue: genericValue) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &genericValue, { value.copyBytes(to: $0)} )
        return genericValue
    }
}
