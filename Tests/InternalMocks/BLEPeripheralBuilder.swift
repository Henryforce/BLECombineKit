//
//  BLEPeripheralBuilder.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 10/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation
@testable import BLECombineKit

/// Internal only: Used for returning nil peripheral on multiple build calls
public final class MockArrayBLEPeripheralBuilder: BLEPeripheralBuilder {
    
    public init() {  }
    
    public var buildBLEPeripheralWasCalledCount = 0
    public var blePeripherals = [BLEPeripheral?]()
    public func build(
        from peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager
    ) -> BLEPeripheral? {
        let peripheral = blePeripherals.element(at: buildBLEPeripheralWasCalledCount)
        buildBLEPeripheralWasCalledCount += 1
        return peripheral ?? nil
    }
}
