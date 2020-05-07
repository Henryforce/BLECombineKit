//
//  BLECombineKitTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 7/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import XCTest
import BLECombineKit

class BLECombineKitTests: XCTestCase {
    
    func testBLECombineKitInitReturnsBLECentralManager() throws {
        let bleCentralManager = BLECombineKit.buildCentralManager()
        XCTAssertNotNil(bleCentralManager.centralManager.manager)
    }

}
