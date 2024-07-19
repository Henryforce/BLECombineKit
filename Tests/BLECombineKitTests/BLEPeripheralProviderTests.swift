//
//  BLEPeripheralProviderTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 18/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import XCTest

@testable import BLECombineKit

final class BLEPeripheralProviderTests: XCTestCase {
  var provider: BLEPeripheralProvider!
  var peripheralWrapper: MockCBPeripheralWrapper!
  var centralManager: MockBLECentralManager!

  override func setUpWithError() throws {
    provider = StandardBLEPeripheralProvider()
    peripheralWrapper = MockCBPeripheralWrapper()
    centralManager = MockBLECentralManager()
  }

  override func tearDownWithError() throws {
    provider = nil
    peripheralWrapper = nil
    centralManager = nil
  }

  func testProviderBuildsPeripheralIfNotPreviouslyStored() throws {
    // Given.
    let identifier = peripheralWrapper.identifier

    // When.
    let firstPeripheral = provider.provide(for: peripheralWrapper, centralManager: centralManager)
    let secondPeripheral = provider.provide(for: peripheralWrapper, centralManager: centralManager)

    // Then.
    let firstAssociatedIdentifier = firstPeripheral.associatedPeripheral.identifier
    let secondAssociatedIdentifier = secondPeripheral.associatedPeripheral.identifier
    XCTAssertEqual(identifier, firstAssociatedIdentifier)
    XCTAssertEqual(identifier, secondAssociatedIdentifier)
    XCTAssertEqual(peripheralWrapper.setupDelegateWasCalledStack.count, 1)
  }
}
