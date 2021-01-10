//
//  MockBLEPeripheralBuilder.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation

public final class MockBLEPeripheralBuilder: BLEPeripheralBuilder {
    public init() { }
    
    public var buildBLEPeripheralWasCalledCount = 0
    public var blePeripheral: BLEPeripheral?
    public func build(
        from peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager
    ) -> BLEPeripheral? {
        buildBLEPeripheralWasCalledCount += 1
        return blePeripheral
    }
}
