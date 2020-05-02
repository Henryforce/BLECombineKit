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
    var cbCentralManagerMock: CBCentralManagerMock!
    var disposable = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        delegate = BLECentralManagerDelegate()
        cbCentralManagerMock = CBCentralManagerMock()
        
        sut = BLECentralManager(centralManager: cbCentralManagerMock, managerDelegate: delegate)
    }

    override func tearDownWithError() throws {
        delegate = nil
        cbCentralManagerMock = nil
        sut = nil
    }
    
    func testScanForPeripheralsReturns() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        let peripheralMock = CBPeripheralWrapperMock()
        var expectedPeripheral: BLEPeripheral?
        
        let scanForPeripheralsObservable = sut.scanForPeripherals(withServices: [], options: nil)
        
        scanForPeripheralsObservable
            .sink(receiveCompletion: { error in
                XCTFail()
            }, receiveValue: { peripheral in
                expectedPeripheral = peripheral
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        XCTAssertTrue(cbCentralManagerMock.scanForPeripheralsWasCalled)
        XCTAssertNil(expectedPeripheral)
        delegate.didDiscoverAdvertisementData.send((peripheral: peripheralMock, advertisementData: [:], rssi: NSNumber.init(value: 0)))
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedPeripheral)
    }
    
    func testConnectCallsCentralManager() throws {
        let peripheral = CBPeripheralWrapperMock()
        
        sut.connect(peripheralWrapper: peripheral, options: nil)
        
        XCTAssertTrue(cbCentralManagerMock.connectWasCalled)
    }

}
