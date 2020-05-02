//
//  BLEPeripheralTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import XCTest
import CoreBluetooth
import Combine
@testable import BLECombineKit

class BLEPeripheralTests: XCTestCase {

    var sut: BLEPeripheral!
    var delegate: BLEPeripheralDelegate!
    var centralManagerMock: BLECentralManagerMock!
    var peripheralMock: CBPeripheralWrapperMock!
    var disposable = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        delegate = BLEPeripheralDelegate()
        centralManagerMock = BLECentralManagerMock()
        peripheralMock = CBPeripheralWrapperMock()
        
        sut = BLEPeripheral(peripheral: peripheralMock, centralManager: centralManagerMock, delegate: delegate)
    }

    override func tearDownWithError() throws {
        delegate = nil
        centralManagerMock = nil
        peripheralMock = nil
        sut = nil
    }

    func testConnectCallsCentralManagerToConnectPeripheral() throws {
        _ = sut.connect(with: nil)

        XCTAssertTrue(centralManagerMock.connectWasCalled)
    }
    
    func testConnectCallsCentralManagerToConnectPeripheralAndReturnsWhenConnectionStateIsTrue() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedPeripheral: BLEPeripheral?
        
        let peripheralConnectedObservable = sut.connect(with: nil)
        
        peripheralConnectedObservable
            .sink(receiveCompletion: { error in
                XCTFail()
            }, receiveValue: { peripheral in
                expectedPeripheral = peripheral
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        XCTAssertTrue(centralManagerMock.connectWasCalled)
        XCTAssertNil(expectedPeripheral)
        sut.connectionState.send(true)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(expectedPeripheral?.connectionState.value ?? false)
    }
    
    func testDiscoverServiceReturns() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedService: BLEService?
        
        let servicesObservable = sut.discoverServices(serviceUUIDs: nil)
        
        servicesObservable
            .sink(receiveCompletion: { error in
                XCTFail()
            }, receiveValue: { service in
                expectedService = service
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        XCTAssertTrue(peripheralMock.discoverServicesWasCalled)
        XCTAssertNil(expectedService)
        delegate.didDiscoverServices.send(peripheralMock)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedService)
    }
    
    func testDiscoverCharacteristicReturns() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedCharacteristic: BLECharacteristic?
        
        let service = CBMutableService.init(type: CBUUID.init(string: "0x0000"), primary: true)
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        service.characteristics = [mutableCharacteristic]
        
        let characteristicsObservable = sut.discoverCharacteristics(characteristicUUIDs: nil, for: service)
        
        characteristicsObservable
            .sink(receiveCompletion: { error in
                XCTFail()
            }, receiveValue: { characteristic in
                expectedCharacteristic = characteristic
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        XCTAssertTrue(peripheralMock.discoverCharacteristicsWasCalled)
        XCTAssertNil(expectedCharacteristic)
        delegate.didDiscoverCharacteristics.send((peripheral: peripheralMock, service: service))
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedCharacteristic)
    }
    
    func testObserveValueReturns() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedData: BLEData?
        
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        let dataObservable = sut.observeValue(for: mutableCharacteristic)
        
        dataObservable
            .sink(receiveCompletion: { error in
                XCTFail()
            }, receiveValue: { data in
                expectedData = data
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        XCTAssertNil(expectedData)
        delegate.didUpdateValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic))
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedData)
    }
    
    func testObserveValueUpdateAndSetNotificationReturns() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedData: BLEData?
        
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        let dataObservable = sut.observeValueUpdateAndSetNotification(for: mutableCharacteristic)
        
        dataObservable
            .sink(receiveCompletion: { error in
                XCTFail()
            }, receiveValue: { data in
                expectedData = data
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        XCTAssertTrue(peripheralMock.setNotifyValueWasCalled)
        XCTAssertNil(expectedData)
        delegate.didUpdateValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic))
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedData)
    }
    
    func testObserveRSSIValueReturns() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedData: NSNumber?
        
        let rssiObservable = sut.observeRSSIValue()
            
        rssiObservable
            .sink(receiveCompletion: { error in
                XCTFail()
            }, receiveValue: { data in
                expectedData = data
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        XCTAssertNil(expectedData)
        delegate.didReadRSSI.send((peripheral: peripheralMock, rssi: NSNumber.init(value: 0)))
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedData)
    }
    
    func testConvenienceInit() {
        let peripheralMock = CBPeripheralWrapperMock()
        
        sut = BLEPeripheral.init(peripheral: peripheralMock, centralManager: nil)
        
        XCTAssertNotNil(sut)
    }

}
