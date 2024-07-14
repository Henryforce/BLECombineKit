//
//  BLECombineKitTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 7/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import BLECombineKit
import XCTest

final class BLECombineKitTests: XCTestCase {

  func testBLECombineKitInitReturnsBLECentralManager() throws {
    let bleCentralManager = BLECombineKit.buildCentralManager()
    XCTAssertNotNil(bleCentralManager.associatedCentralManager)
  }

}
