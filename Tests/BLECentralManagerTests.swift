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
    var centralManagerWrapper: MockCBCentralManagerWrapper!
    var peripheralBuilder: MockBLEPeripheralBuilder!
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        delegate = BLECentralManagerDelegate()
        centralManagerWrapper = MockCBCentralManagerWrapper()
        peripheralBuilder = MockBLEPeripheralBuilder()
        
        sut = StandardBLECentralManager(
            centralManager: centralManagerWrapper,
            managerDelegate: delegate,
            peripheralBuilder: peripheralBuilder
        )
    }

    override func tearDownWithError() throws {
        delegate = nil
        centralManagerWrapper = nil
        peripheralBuilder = nil
        sut = nil
    }
    
    func testScanForPeripheralsReturns() throws {
        // Given
        let expectation = XCTestExpectation(description: self.debugDescription)
        let peripheralMock = MockCBPeripheralWrapper()
        var expectedScanResult: BLEScanResult?
        let mockedPeripheral = MockBLEPeripheral()
        peripheralBuilder.blePeripheral = mockedPeripheral
        
        // When
        sut.scanForPeripherals(withServices: [], options: nil)
            .sink(receiveCompletion: { _ in
                XCTFail("Scan for Peripherals should not complete")
            }, receiveValue: { scanResult in
                expectedScanResult = scanResult
                expectation.fulfill()
            }).store(in: &cancellables)
        delegate.didDiscoverAdvertisementData.send((peripheral: peripheralMock, advertisementData: [:], rssi: NSNumber.init(value: 0)))
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertNotNil(expectedScanResult)
        XCTAssertNotNil(expectedScanResult?.peripheral)
        XCTAssertEqual(centralManagerWrapper.scanForPeripheralsWasCalledCount, 1)
    }
    
    func testScanForPeripheralsReturnsScanResultsOnlyIfBuilderSuccessfullyBuilds() throws {
        // Given
        let arrayPeripheralBuilder = MockArrayBLEPeripheralBuilder()
        sut = StandardBLECentralManager(
            centralManager: centralManagerWrapper,
            managerDelegate: delegate,
            peripheralBuilder: arrayPeripheralBuilder
        )
        let expectation = XCTestExpectation(description: self.debugDescription)
        let peripheralMock = MockCBPeripheralWrapper()
        let mockedPeripheral = MockBLEPeripheral()
        var scanCounter = 0
        arrayPeripheralBuilder.blePeripherals = [mockedPeripheral, nil, mockedPeripheral]
        
        // When
        sut.scanForPeripherals(withServices: [], options: nil)
            .sink(receiveCompletion: { _ in
                XCTFail("Scan for Peripherals should not complete")
            }, receiveValue: { _ in
                scanCounter += 1
                if scanCounter >= 2 {
                    expectation.fulfill()
                }
            }).store(in: &cancellables)
        delegate.didDiscoverAdvertisementData.send((peripheral: peripheralMock, advertisementData: [:], rssi: NSNumber.init(value: 0)))
        delegate.didDiscoverAdvertisementData.send((peripheral: peripheralMock, advertisementData: [:], rssi: NSNumber.init(value: 0)))
        delegate.didDiscoverAdvertisementData.send((peripheral: peripheralMock, advertisementData: [:], rssi: NSNumber.init(value: 0)))
        
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertEqual(centralManagerWrapper.scanForPeripheralsWasCalledCount, 1)
        XCTAssertEqual(arrayPeripheralBuilder.buildBLEPeripheralWasCalledCount, 3)
    }
    
    func testConnectCallsCentralManager() throws {
        // Given
        let peripheral = MockCBPeripheralWrapper()
        
        // When
        sut.connect(peripheralWrapper: peripheral, options: nil)
        
        // Then
        XCTAssertEqual(centralManagerWrapper.connectWasCalledCount, 1)
    }
    
    func testStopScanCallsCentralManager() throws {
        // When
        sut.stopScan()
        
        // Then
        XCTAssertEqual(centralManagerWrapper.stopScanWasCalledCount, 1)
    }
    
    func testCancelPeripheralConnectionCallsCentralManager() throws {
        // Given
        let peripheral = MockCBPeripheralWrapper()
        
        // When
        _ = sut.cancelPeripheralConnection(peripheral)
        
        // Then
        XCTAssertEqual(centralManagerWrapper.cancelPeripheralConnectionWasCalledCount, 1)
    }
    
    func testRegisterForConnectionEventsCallsCentralManager() {
        // When
        sut.registerForConnectionEvents(options: nil)
        
        // Then
        XCTAssertEqual(centralManagerWrapper.registerForConnectionEventsWasCalledCount, 1)
    }
    
    func testRetrievePeripheralsReturns() throws {
        // Given
        var retrievedPeripheral: BLEPeripheral?
        let peripheralExpectation = expectation(description: "PeripheralExpectation")
        
        // When
        sut.retrievePeripherals(withIdentifiers: [])
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else { return }
                peripheralExpectation.fulfill()
            }, receiveValue: { peripheral in
                retrievedPeripheral = peripheral
            }).store(in: &cancellables)
        
        // Then
        wait(for: [peripheralExpectation], timeout: 0.005)
        XCTAssertNil(retrievedPeripheral) // BLEPeripheralBuilder is returning nil, so no peripherals returned
        XCTAssertEqual(centralManagerWrapper.retrievePeripheralsWasCalledCount, 1)
        XCTAssertEqual(peripheralBuilder.buildBLEPeripheralWasCalledCount, 1)
    }
    
    func testRetrieveConnectedPeripheralsReturns() throws {
        // Given
        var retrievedPeripheral: BLEPeripheral?
        let peripheralExpectation = expectation(description: "PeripheralExpectation")
        
        // When
        sut.retrieveConnectedPeripherals(withServices: [])
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else { return }
                peripheralExpectation.fulfill()
            }, receiveValue: { peripheral in
                retrievedPeripheral = peripheral
            }).store(in: &cancellables)
        
        // Then
        wait(for: [peripheralExpectation], timeout: 0.005)
        XCTAssertNil(retrievedPeripheral) // BLEPeripheralBuilder is returning nil, so no peripherals returned
        XCTAssertEqual(centralManagerWrapper.retrieveConnectedPeripheralsWasCalledCount, 1)
        XCTAssertEqual(peripheralBuilder.buildBLEPeripheralWasCalledCount, 1)
    }
    
    func testWillRestoreStateReturnsWhenDelegateUpdates() {
        // Given
        let willRestoreStateExpectation = expectation(description: "PeripheralExpectation")
        let stateDictionary = ["MockedKey": "MockValue"]
        var observedStateDictionary: [String: Any]?
        
        // When
        sut.observeWillRestoreState()
            .sink(receiveCompletion: { completion in
                XCTFail("observeWillRestoreState should never complete")
            }, receiveValue: { stateDict in
                observedStateDictionary = stateDict
                willRestoreStateExpectation.fulfill()
            }).store(in: &cancellables)
        delegate.willRestoreState.send(stateDictionary)
        
        // Then
        wait(for: [willRestoreStateExpectation], timeout: 0.005)
        XCTAssertEqual(observedStateDictionary!["MockedKey"] as! String, stateDictionary["MockedKey"]!)
    }
    
    func testObserveDidUpdateANCSAuthorizationWhenDelegateUpdates() {
        // Given
        let observeDidUpdateANCSAuthorizationExpectation = expectation(description: "PeripheralExpectation")
        let mockedCBPeripheralWrapper = MockCBPeripheralWrapper()
        peripheralBuilder.blePeripheral = MockBLEPeripheral()
        var observedPeripheral: BLEPeripheral?
        
        // When
        sut.observeDidUpdateANCSAuthorization()
            .sink(receiveCompletion: { completion in
                XCTFail("ObserveDidUpdateANCSAuthorization should never complete")
            }, receiveValue: { peripheral in
                observedPeripheral = peripheral
                observeDidUpdateANCSAuthorizationExpectation.fulfill()
            })
            .store(in: &cancellables)
        delegate.didUpdateANCSAuthorization.send(mockedCBPeripheralWrapper)
        
        // Then
        wait(for: [observeDidUpdateANCSAuthorizationExpectation], timeout: 0.005)
        XCTAssertEqual(peripheralBuilder.buildBLEPeripheralWasCalledCount, 1)
        XCTAssertNotNil(observedPeripheral)
    }

}
