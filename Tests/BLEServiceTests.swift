//
//  BLEServiceTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BLECombineKit

class BLEServiceTests: XCTestCase {

    var blePeripheralMock: MockBLEPeripheral!
    
    override func setUpWithError() throws {
        blePeripheralMock = MockBLEPeripheral()
    }

    override func tearDownWithError() throws {
        blePeripheralMock = nil
    }

    func testDiscoverCharacteristicsCallsBLEPeripheral() throws {
        let cbService = CBMutableService.init(type: CBUUID.init(string: "0x0000"), primary: true)
        let sut = BLEService(value: cbService, peripheral: blePeripheralMock)
        
        _ = sut.discoverCharacteristics(characteristicUUIDs: [])
        
        XCTAssertTrue(blePeripheralMock.discoverCharacteristicsWasCalled)
    }

}
