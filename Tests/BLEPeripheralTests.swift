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
    
    func testObserveConnectionState() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut.observeConnectionState()
            .sink(receiveValue: { value in
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        wait(for: [expectation], timeout: 0.1)
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
        delegate.didDiscoverServices.send((peripheral: peripheralMock, error: nil))
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
        delegate.didDiscoverCharacteristics.send((peripheral: peripheralMock, service: service, error: nil))
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
        
        XCTAssertTrue(peripheralMock.readValueForCharacteristicWasCalled)
        XCTAssertNil(expectedData)
        delegate.didUpdateValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil))
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
        delegate.didUpdateValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil))
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
        
        XCTAssertTrue(peripheralMock.readRSSIWasCalled)
        XCTAssertNil(expectedData)
        delegate.didReadRSSI.send((peripheral: peripheralMock, rssi: NSNumber.init(value: 0), error: nil))
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedData)
    }
    
    func testWriteValueWithoutResponseReturnsImmediately() {
        var expectedResult: Bool?
        var completion: Subscribers.Completion<BLEError>?
        
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        sut.writeValue(Data(), for: mutableCharacteristic, type: .withoutResponse)
            .sink(receiveCompletion: { event in
                completion = event
            }, receiveValue: { result in
                expectedResult = result
            })
            .store(in: &disposable)
        
        XCTAssertTrue(peripheralMock.writeValueForCharacteristicWasCalled)
        XCTAssertNotNil(expectedResult)
        XCTAssertNotNil(completion)
    }
    
    func testWriteValueWithResponseReturnsOnDelegateCall() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedResult: Bool?
        
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        sut.writeValue(Data(), for: mutableCharacteristic, type: .withResponse)
            .sink(receiveCompletion: { error in
                XCTFail()
            }, receiveValue: { result in
                expectedResult = result
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        XCTAssertNil(expectedResult)
        delegate.didWriteValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil))
        XCTAssertTrue(peripheralMock.writeValueForCharacteristicWasCalled)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedResult)
    }
    
    func testWriteValueWithResponseReturnsErrorOnDelegateErrorCall() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        sut.writeValue(Data(), for: mutableCharacteristic, type: .withResponse)
            .sink(receiveCompletion: { error in
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail()
            })
            .store(in: &disposable)
        
        delegate.didWriteValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic, error: BLEError.unknown))
        XCTAssertTrue(peripheralMock.writeValueForCharacteristicWasCalled)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testDisconnectCallsCentralManager() throws {
        _ = sut.disconnect()
        
        XCTAssertTrue(centralManagerMock.cancelPeripheralConnectionWasCalled)
    }
    
    func testConvenienceInit() {
        let peripheralMock = CBPeripheralWrapperMock()
        
        sut = BLEPeripheral.init(peripheral: peripheralMock, centralManager: nil)
        
        XCTAssertNotNil(sut)
    }

}
