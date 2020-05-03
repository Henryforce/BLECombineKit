//
//  BLECentralManagerTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import XCTest
import CoreBluetooth
import Combine
@testable import BLECombineKit

class BLECentralManagerTests: XCTestCase {

    var sut: BLECentralManager!
    var delegate: BLECentralManagerDelegate!
    var cbCentralManagerMock: CBCentralManagerWrapperMock!
    var disposable = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        delegate = BLECentralManagerDelegate()
        cbCentralManagerMock = CBCentralManagerWrapperMock()
        
        sut = BLECentralManagerImpl(centralManager: cbCentralManagerMock, managerDelegate: delegate)
    }

    override func tearDownWithError() throws {
        delegate = nil
        cbCentralManagerMock = nil
        sut = nil
    }
    
    func testScanForPeripheralsReturns() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        let peripheralMock = CBPeripheralWrapperMock()
        var expectedScanResult: BLEScanResult?
        
        let scanForPeripheralsObservable = sut.scanForPeripherals(withServices: [], options: nil)
        
        scanForPeripheralsObservable
            .sink(receiveCompletion: { error in
                XCTFail()
            }, receiveValue: { scanResult in
                expectedScanResult = scanResult
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        XCTAssertTrue(cbCentralManagerMock.scanForPeripheralsWasCalled)
        XCTAssertNil(expectedScanResult)
        delegate.didDiscoverAdvertisementData.send((peripheral: peripheralMock, advertisementData: [:], rssi: NSNumber.init(value: 0)))
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedScanResult)
    }
    
    func testConnectCallsCentralManager() throws {
        let peripheral = CBPeripheralWrapperMock()
        
        sut.connect(peripheralWrapper: peripheral, options: nil)
        
        XCTAssertTrue(cbCentralManagerMock.connectWasCalled)
    }
    
    func testStopScanCallsCentralManager() throws {
        sut.stopScan()
        
        XCTAssertTrue(cbCentralManagerMock.stopScanWasCalled)
    }
    
    func testCancelPeripheralConnectionCallsCentralManager() throws {
        let peripheral = CBPeripheralWrapperMock()
        
        _ = sut.cancelPeripheralConnection(peripheral)
        
        XCTAssertTrue(cbCentralManagerMock.cancelPeripheralConnectionWasCalled)
    }
    
    func testRegisterForConnectionEventsCallsCentralManager() {
        sut.registerForConnectionEvents(options: nil)
        
        XCTAssertTrue(cbCentralManagerMock.registerForConnectionEventsWasCalled)
    }

}
