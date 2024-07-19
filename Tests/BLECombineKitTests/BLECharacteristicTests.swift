//
//  BLECharacteristicTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import CoreBluetooth
import XCTest

@testable import BLECombineKit

final class BLECharacteristicTests: XCTestCase {

  var blePeripheralMock: MockBLEPeripheral!

  override func setUpWithError() throws {
    blePeripheralMock = MockBLEPeripheral()
  }

  override func tearDownWithError() throws {
    blePeripheralMock = nil
  }

  func testObserveValueCallsBLEPeripheral() throws {
    // Given.
    let cbCharacteristic = CBMutableCharacteristic(
      type: CBUUID.init(string: "0x0000"),
      properties: CBCharacteristicProperties.init(),
      value: Data(),
      permissions: CBAttributePermissions.init()
    )
    let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)

    // When.
    _ = sut.observeValue()

    // Then.
    XCTAssertTrue(blePeripheralMock.observeValueWasCalled)
  }

  func testObserveValueUpdateWithNotificationCallsBLEPeripheral() throws {
    let cbCharacteristic = CBMutableCharacteristic(
      type: CBUUID.init(string: "0x0000"),
      properties: CBCharacteristicProperties.init(),
      value: Data(),
      permissions: CBAttributePermissions.init()
    )
    let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)

    _ = sut.observeValueUpdateAndSetNotification()

    XCTAssertTrue(blePeripheralMock.observeValueUpdateAndSetNotificationWasCalled)
  }

  func testSetNotifyValue() {
    // Given.
    let cbCharacteristic = CBMutableCharacteristic(
      type: CBUUID.init(string: "0x0000"),
      properties: CBCharacteristicProperties.init(),
      value: Data(),
      permissions: CBAttributePermissions.init()
    )
    let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)
    let expectedSetNotifyStack: [SetNotifyValueWasCalledStackValue] = [
      SetNotifyValueWasCalledStackValue(enabled: true, characteristic: cbCharacteristic),
      SetNotifyValueWasCalledStackValue(enabled: false, characteristic: cbCharacteristic),
    ]

    // When.
    sut.setNotifyValue(true)
    sut.setNotifyValue(false)

    // Then.
    XCTAssertEqual(expectedSetNotifyStack, blePeripheralMock.setNotifyValueWasCalledStack)
  }

  func testWriteValue() {
    let cbCharacteristic = CBMutableCharacteristic(
      type: CBUUID.init(string: "0x0000"),
      properties: CBCharacteristicProperties.init(),
      value: Data(),
      permissions: CBAttributePermissions.init()
    )
    let sut = BLECharacteristic(value: cbCharacteristic, peripheral: blePeripheralMock)

    _ = sut.writeValue(Data(), type: .withResponse)

    XCTAssertTrue(blePeripheralMock.writeValueWasCalled)
  }

}
