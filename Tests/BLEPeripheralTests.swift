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

    var sut: StandardBLEPeripheral!
    var delegate: BLEPeripheralDelegate!
    var centralManager: MockBLECentralManager!
    var peripheralMock: MockCBPeripheralWrapper!
    var disposable = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        delegate = BLEPeripheralDelegate()
        centralManager = MockBLECentralManager()
        peripheralMock = MockCBPeripheralWrapper()
        
        sut = StandardBLEPeripheral(
            peripheral: peripheralMock,
            centralManager: centralManager,
            delegate: delegate
        )
    }

    override func tearDownWithError() throws {
        delegate = nil
        centralManager = nil
        peripheralMock = nil
        sut = nil
    }
    
    func testObserveConnectionState() {
        // Given
        let expectation = XCTestExpectation(description: #function)
        
        // When
        sut.observeConnectionState()
            .sink(receiveValue: { value in
                expectation.fulfill()
            })
            .store(in: &disposable)
        
        // Then
        wait(for: [expectation], timeout: 0.1)
    }

    func testConnectCallsCentralManagerToConnectPeripheral() throws {
        // When
        _ = sut.connect(with: nil)

        // Then
        XCTAssertEqual(centralManager.connectWasCalledCount, 1)
    }
    
    func testConnectCallsCentralManagerToConnectPeripheralAndReturnsWhenConnectionStateIsTrue() throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        var expectedPeripheral: BLEPeripheralState?
        
        // When
        sut.connect(with: nil)
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { peripheral in
                expectedPeripheral = peripheral as? BLEPeripheralState
            })
            .store(in: &disposable)
        sut.connectionState.send(true)
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertTrue(expectedPeripheral?.connectionState.value ?? false)
        XCTAssertEqual(centralManager.connectWasCalledCount, 1)
    }
    
    func testDiscoverServicesReturnsWhenPeripheralAlreadyFoundServices() throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        var expectedService: BLEService?
        let mutableService = CBMutableService(type: CBUUID.init(), primary: true)
        peripheralMock.mockedServices = [mutableService]
        
        // When
        sut.discoverServices(serviceUUIDs: nil)
            .sink(receiveCompletion: { error in
                expectation.fulfill()
            }, receiveValue: { service in
                expectedService = service
            }).store(in: &disposable)
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertFalse(peripheralMock.discoverServicesWasCalled)
        XCTAssertNotNil(expectedService)
    }
    
    func testDiscoverServicesReturnsDelegateObservable() throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        let mutableService = CBMutableService(type: CBUUID.init(), primary: true)
        var expectedService: BLEService?
        peripheralMock.mockedServices = nil
        
        // When
        sut.discoverServices(serviceUUIDs: nil)
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else { return }
                expectation.fulfill()
            }, receiveValue: { service in
                expectedService = service
            }).store(in: &disposable)
        peripheralMock.mockedServices = [mutableService]
        delegate.didDiscoverServices.send((peripheral: peripheralMock, error: nil))
        
        // Then
        wait(for: [expectation], timeout: 0.5)
        XCTAssertNotNil(expectedService)
        XCTAssertTrue(peripheralMock.discoverServicesWasCalled)
    }
    
    func testDiscoverCharacteristicReturns() throws {
        // Given
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedCharacteristic: BLECharacteristic?
        let service = CBMutableService.init(type: CBUUID.init(string: "0x0000"), primary: true)
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        service.characteristics = [mutableCharacteristic]
    
        // When
        sut.discoverCharacteristics(characteristicUUIDs: nil, for: service)
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else { return }
                expectation.fulfill()
            }, receiveValue: { characteristic in
                expectedCharacteristic = characteristic
            }).store(in: &disposable)
        delegate.didDiscoverCharacteristics.send((peripheral: peripheralMock, service: service, error: nil))
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertNotNil(expectedCharacteristic)
        XCTAssertTrue(peripheralMock.discoverCharacteristicsWasCalled)
    }
    
    func testObserveValueReturns() throws {
        // Given
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedData: BLEData?
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        // When
        sut.observeValue(for: mutableCharacteristic)
            .sink(receiveCompletion: { error in
                XCTFail("Observe Value should never complete")
            }, receiveValue: { data in
                expectedData = data
                expectation.fulfill()
            }).store(in: &disposable)
        delegate.didUpdateValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil))
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertNotNil(expectedData)
        XCTAssertTrue(peripheralMock.readValueForCharacteristicWasCalled)
    }
    
    func testObserveValueUpdateAndSetNotificationReturns() throws {
        // Given
        let expectation = XCTestExpectation(description: self.debugDescription)
        var expectedData: BLEData?
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        // When
        sut.observeValueUpdateAndSetNotification(for: mutableCharacteristic)
            .sink(receiveCompletion: { error in
                XCTFail("Observe Value Update and Set Notification should never complete")
            }, receiveValue: { data in
                expectedData = data
                expectation.fulfill()
            }).store(in: &disposable)
        delegate.didUpdateValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil))
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertNotNil(expectedData)
        XCTAssertTrue(peripheralMock.setNotifyValueWasCalled)
    }
    
    func testSetNotifyValue() {
        // Given
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        // When
        sut.setNotifyValue(true, for: mutableCharacteristic)
        
        // Then
        XCTAssertTrue(peripheralMock.setNotifyValueWasCalled)
    }
    
    func testObserveNameValueReturns() {
        // Given
        let expectation = XCTestExpectation(description: self.debugDescription)
        let dataToSend = "MockedPeripheral"
        var expectedData: String?
        
        // When
        sut.observeNameValue()
            .sink(receiveCompletion: { error in
                XCTFail("Observe Name Value should never complete")
            }, receiveValue: { data in
                expectedData = data
                expectation.fulfill()
            }).store(in: &disposable)
        delegate.didUpdateName.send(peripheralMock)
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertEqual(expectedData!, dataToSend)
    }
    
    func testObserveRSSIValueReturns() {
        // Given
        let expectation = XCTestExpectation(description: self.debugDescription)
        let dataToSend = NSNumber.init(value: 0)
        var expectedData: NSNumber?
        
        // When
        sut.observeRSSIValue()
            .sink(receiveCompletion: { error in
                XCTFail("Observe RSSI Value should never complete")
            }, receiveValue: { data in
                expectedData = data
                expectation.fulfill()
            }).store(in: &disposable)
        delegate.didReadRSSI.send((peripheral: peripheralMock, rssi: dataToSend, error: nil))
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertEqual(expectedData!, dataToSend)
    }
    
    func testWriteValueWithoutResponseReturnsImmediately() {
        // Given
        let expectation = XCTestExpectation(description: #function)
        var expectedResult: Bool?
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        // When
        sut.writeValue(Data(), for: mutableCharacteristic, type: .withoutResponse)
            .sink(receiveCompletion: { event in
                expectation.fulfill()
            }, receiveValue: { result in
                expectedResult = result
            }).store(in: &disposable)
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertTrue(peripheralMock.writeValueForCharacteristicWasCalled)
        XCTAssertNotNil(expectedResult)
    }
    
    func testWriteValueWithResponseReturnsOnDelegateCall() {
        // Given
        let expectation = XCTestExpectation(description: #function)
        var expectedResult: Bool?
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        // When
        sut.writeValue(Data(), for: mutableCharacteristic, type: .withResponse)
            .sink(receiveCompletion: { error in
                expectation.fulfill()
            }, receiveValue: { result in
                expectedResult = result
            }).store(in: &disposable)
        delegate.didWriteValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil))
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertNotNil(expectedResult)
        XCTAssertTrue(peripheralMock.writeValueForCharacteristicWasCalled)
    }
    
    func testWriteValueWithResponseReturnsErrorOnDelegateErrorCall() {
        // Given
        let expectation = XCTestExpectation(description: #function)
        let mutableCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: "0x0000"), properties: CBCharacteristicProperties.init(), value: Data(), permissions: CBAttributePermissions.init())
        
        // When
        sut.writeValue(Data(), for: mutableCharacteristic, type: .withResponse)
            .sink(receiveCompletion: { error in
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail()
            })
            .store(in: &disposable)
        delegate.didWriteValueForCharacteristic.send((peripheral: peripheralMock, characteristic: mutableCharacteristic, error: BLEError.unknown))
        
        // Then
        wait(for: [expectation], timeout: 0.005)
        XCTAssertTrue(peripheralMock.writeValueForCharacteristicWasCalled)
    }
    
    func testDisconnectCallsCentralManager() throws {
        // When
        _ = sut.disconnect()

        // Then
        XCTAssertEqual(centralManager.cancelPeripheralConnectionWasCalledCount, 1)
    }
    
    func testDisconnectCallsCentralManagerButReturnsFalseWhenManagerIsNil() throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        centralManager = nil
        sut = StandardBLEPeripheral(peripheral: peripheralMock, centralManager: centralManager, delegate: delegate)
        
        // When
        sut.disconnect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    if case .disconnectionFailed = error {
                        expectation.fulfill()
                    }
                case .finished:
                    XCTFail("Error should have been returned on completion")
                }
            }, receiveValue: { result in
                XCTFail("No value should have been received")
            })
            .store(in: &disposable)
        
        // Then
        wait(for: [expectation], timeout: 0.005)
    }
    
    func testConvenienceInit() {
        // Given
        let peripheralMock = MockCBPeripheralWrapper()
        
        // When
        sut = StandardBLEPeripheral.init(peripheral: peripheralMock, centralManager: nil)
        
        // Then
        XCTAssertNotNil(sut)
    }

}
