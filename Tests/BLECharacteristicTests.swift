//
//  BLECharacteristicTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import XCTest
import CoreBluetooth
import BLECombineKitMocks
@testable import BLECombineKit

class BLECharacteristicTests: XCTestCase {

    var blePeripheralMock: MockBLEPeripheral!
    
    override func setUpWithError() throws {
        blePeripheralMock = MockBLEPeripheral()
    }

    override func tearDownWithError() throws {
        blePeripheralMock = nil
    }

    func testObserveValueCallsBLEPeripheral() throws {
        let cbCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)
        
        _ = sut.observeValue()
        
        XCTAssertEqual(blePeripheralMock.observeValueWasCalledCount, 1)
    }
    
    func testObserveValueUpdateWithNotificationCallsBLEPeripheral() throws {
        let cbCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)
        
        _ = sut.observeValueUpdateAndSetNotification()
        
        XCTAssertEqual(blePeripheralMock.observeValueUpdateAndSetNotificationWasCalledCount, 1)
    }
    
    func testSetNotifyValue() {
        let cbCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)
        
        sut.setNotifyValue(true)
        
        XCTAssertEqual(blePeripheralMock.setNotifyValueWasCalledCount, 1)
    }

}
