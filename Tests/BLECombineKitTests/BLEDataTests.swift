//
//  BLEDataTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 30/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import XCTest

@testable import BLECombineKit

final class BLEDataTests: XCTestCase {

  var mockupPeripheral: MockBLEPeripheral!

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    mockupPeripheral = MockBLEPeripheral()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    mockupPeripheral = nil
  }

  func testGenericDataConversionToFloat() throws {
    var float32 = Float32(12.99)
    var float32Data = Data()

    withUnsafePointer(
      to: &float32,
      { (ptr: UnsafePointer<Float32>) -> Void in
        float32Data = Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
      }
    )

    let data = BLEData(value: float32Data)

    if let result = data.to(type: Float32.self) {
      XCTAssertEqual(float32, result, accuracy: 0.000001)
    } else {
      XCTFail()
    }
  }

}
