//
//  BLECharacteristicTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BLECombineKit

class BLECharacteristicTests: XCTestCase {

    var blePeripheralMock: BLEPeripheralMock!
    
    override func setUpWithError() throws {
        blePeripheralMock = BLEPeripheralMock()
    }

    override func tearDownWithError() throws {
        blePeripheralMock = nil
    }

    func testObserveValueCallsBLEPeripheral() throws {
        let cbCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)
        
        _ = sut.observeValue()
        
        XCTAssertTrue(blePeripheralMock.observeValueWasCalled)
    }
    
    func testObserveValueUpdateWithNotificationCallsBLEPeripheral() throws {
        let cbCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)
        
        _ = sut.observeValueUpdateAndSetNotification()
        
        XCTAssertTrue(blePeripheralMock.observeValueUpdateAndSetNotificationWasCalled)
    }
    
    func testSetNotifyValue() {
        let cbCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)
        
        sut.setNotifyValue(true, for: cbCharacteristic)
        
        XCTAssertTrue(blePeripheralMock.setNotifyValueWasCalled)
    }

}
