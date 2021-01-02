//
//  MockBLEPeripheralBuilder.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation
@testable import BLECombineKit

final class MockBLEPeripheralBuilder: BLEPeripheralBuilder {
    var buildBLEPeripheralWasCalledCount = 0
    var blePripheral: BLEPeripheral?
    func build(
        from peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager
    ) -> BLEPeripheral? {
        buildBLEPeripheralWasCalledCount += 1
        return blePripheral
    }
}
