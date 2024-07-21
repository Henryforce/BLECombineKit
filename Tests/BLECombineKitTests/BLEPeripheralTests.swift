//
//  BLEPeripheralTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import XCTest

@testable import BLECombineKit

final class BLEPeripheralTests: XCTestCase {

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
    // Given
    let associatedManager = MockCBCentralManagerWrapper()
    centralManager.associatedCentralManager = associatedManager

    // When
    _ = sut.connect(with: nil)

    // Then
    XCTAssertEqual(associatedManager.connectWasCalledCount, 1)
  }

  func testConnectCallsCentralManagerToConnectPeripheralAndReturnsWhenConnectionStateIsTrue() throws
  {
    // Given
    let associatedManager = MockCBCentralManagerWrapper()
    centralManager.associatedCentralManager = associatedManager
    let expectation = XCTestExpectation(description: #function)
    var expectedPeripheral: BLETrackedPeripheral?

    // When
    sut.connect(with: nil)
      .sink(
        receiveCompletion: { completion in
          expectation.fulfill()
        },
        receiveValue: { peripheral in
          expectedPeripheral = peripheral as? BLETrackedPeripheral
        }
      )
      .store(in: &disposable)
    sut.connectionState.send(true)

    // Then
    wait(for: [expectation], timeout: 0.005)
    XCTAssertTrue(expectedPeripheral?.connectionState.value ?? false)
    XCTAssertEqual(associatedManager.connectWasCalledCount, 1)
  }

  func testDiscoverServicesReturnsWhenPeripheralAlreadyFoundServices() throws {
    // Given
    let expectation = XCTestExpectation(description: #function)
    var expectedService: BLEService?
    let mutableService = CBMutableService(type: CBUUID(), primary: true)
    peripheralMock.mockedServices = [mutableService]

    // When
    sut.discoverServices(serviceUUIDs: nil)
      .sink(
        receiveCompletion: { error in
          expectation.fulfill()
        },
        receiveValue: { service in
          expectedService = service
        }
      ).store(in: &disposable)

    // Then
    wait(for: [expectation], timeout: 0.005)
    XCTAssertFalse(peripheralMock.discoverServicesWasCalled)
    XCTAssertNotNil(expectedService)
  }

  func testDiscoverServicesReturnsDelegateObservable() throws {
    // Given
    let expectation = XCTestExpectation(description: #function)
    let mutableService = CBMutableService(type: CBUUID(), primary: true)
    var expectedService: BLEService?
    peripheralMock.mockedServices = nil

    // When
    sut.discoverServices(serviceUUIDs: nil)
      .sink(
        receiveCompletion: { completion in
          guard case .finished = completion else { return }
          expectation.fulfill()
        },
        receiveValue: { service in
          expectedService = service
        }
      ).store(in: &disposable)
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
    let service = CBMutableService(type: CBUUID(string: "0x0000"), primary: true)
    let mutableCharacteristic = commonMutableCharacteristic()
    service.characteristics = [mutableCharacteristic]

    // When
    sut.discoverCharacteristics(characteristicUUIDs: nil, for: service)
      .sink(
        receiveCompletion: { completion in
          guard case .finished = completion else { return }
          expectation.fulfill()
        },
        receiveValue: { characteristic in
          expectedCharacteristic = characteristic
        }
      ).store(in: &disposable)
    delegate.didDiscoverCharacteristics.send(
      (peripheral: peripheralMock, service: service, error: nil)
    )

    // Then
    wait(for: [expectation], timeout: 0.005)
    XCTAssertNotNil(expectedCharacteristic)
    XCTAssertEqual(peripheralMock.discoverCharacteristicsWasCalledStack.count, 1)
  }

  func testDiscoverCharacteristicWithMultipleSubscriptionsCallsDelegateOnlyOnce() throws {
    // Given
    let expectation = XCTestExpectation(description: "self.debugDescription")
    let expectation2 = XCTestExpectation(description: "self.debugDescription 2")
    let service = CBMutableService(type: CBUUID(string: "0x0000"), primary: true)
    let mutableCharacteristic = commonMutableCharacteristic()
    service.characteristics = [mutableCharacteristic]

    // When
    let publisher = sut.discoverCharacteristics(characteristicUUIDs: nil, for: service)

    publisher
      .sink(
        receiveCompletion: { _ in
          expectation.fulfill()
        },
        receiveValue: { _ in
        }
      ).store(in: &disposable)

    publisher
      .sink(
        receiveCompletion: { _ in
          expectation2.fulfill()
        },
        receiveValue: { _ in
        }
      ).store(in: &disposable)
    delegate.didDiscoverCharacteristics.send(
      (peripheral: peripheralMock, service: service, error: nil)
    )

    // Then
    wait(for: [expectation, expectation2], timeout: 0.005)
    XCTAssertEqual(peripheralMock.discoverCharacteristicsWasCalledStack.count, 1)
  }

  func testObserveValueReturns() throws {
    // Given
    let expectation = XCTestExpectation(description: self.debugDescription)
    var expectedData: BLEData?
    let mutableCharacteristic = commonMutableCharacteristic()
    let expectedReadStack = [mutableCharacteristic]

    // When
    sut.observeValue(for: mutableCharacteristic)
      .sink(
        receiveCompletion: { error in
          XCTFail("Observe Value should never complete")
        },
        receiveValue: { data in
          expectedData = data
          expectation.fulfill()
        }
      ).store(in: &disposable)
    delegate.didUpdateValueForCharacteristic.send(
      (peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil)
    )

    // Then
    wait(for: [expectation], timeout: 0.005)
    XCTAssertNotNil(expectedData)
    XCTAssertEqual(expectedReadStack, peripheralMock.readValueForCharacteristicWasCalledStack)
  }

  func testReadValueReturnsSingleValueAndCompletes() throws {
    // Given.
    let valueExpectation = XCTestExpectation(description: "Value received")
    let completionExpectation = XCTestExpectation(description: "Completion called")
    let stringData = "My data"
    let mutableCharacteristic = commonMutableCharacteristic(data: stringData.data(using: .utf8))
    var receivedData: BLEData?
    let expectedReadStack = [mutableCharacteristic]

    // When.
    sut.readValue(for: mutableCharacteristic)
      .sink(
        receiveCompletion: { error in
          completionExpectation.fulfill()
        },
        receiveValue: { data in
          receivedData = data
          valueExpectation.fulfill()
        }
      ).store(in: &disposable)
    delegate.didUpdateValueForCharacteristic.send(
      (peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil)
    )

    // Then.
    wait(for: [valueExpectation, completionExpectation], timeout: 0.01)
    XCTAssertEqual(stringData, receivedData?.string)
    XCTAssertEqual(expectedReadStack, peripheralMock.readValueForCharacteristicWasCalledStack)
  }

  func testReadValueAsASharedPublisherTriggersOnlyOneRead() throws {
    // Given.
    let valueExpectation = XCTestExpectation(description: "Value received")
    let completionExpectation = XCTestExpectation(description: "Completion called")
    let valueExpectation2 = XCTestExpectation(description: "Value received 2")
    let completionExpectation2 = XCTestExpectation(description: "Completion called 2")
    let stringData = "My data"
    let mutableCharacteristic = commonMutableCharacteristic(data: stringData.data(using: .utf8))
    var receivedData: BLEData?
    var receivedData2: BLEData?
    let expectedReadStack = [mutableCharacteristic]
    let resultToSend: DidUpdateValueForCharacteristicResult = (
      peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil
    )

    // When.
    let stream = sut.readValue(for: mutableCharacteristic)
      .share()
    stream
      .sink(
        receiveCompletion: { error in
          completionExpectation.fulfill()
        },
        receiveValue: { data in
          receivedData = data
          valueExpectation.fulfill()
        }
      ).store(in: &disposable)
    stream
      .sink(
        receiveCompletion: { error in
          completionExpectation2.fulfill()
        },
        receiveValue: { data in
          receivedData2 = data
          valueExpectation2.fulfill()
        }
      ).store(in: &disposable)
    delegate.didUpdateValueForCharacteristic.send(resultToSend)
    delegate.didUpdateValueForCharacteristic.send(resultToSend)

    // Then.
    wait(
      for: [valueExpectation, valueExpectation2, completionExpectation, completionExpectation2],
      timeout: 0.01
    )
    XCTAssertEqual(stringData, receivedData?.string)
    XCTAssertEqual(stringData, receivedData2?.string)
    XCTAssertEqual(expectedReadStack, peripheralMock.readValueForCharacteristicWasCalledStack)
  }

  func testObserveValueUpdateAndSetNotificationReturns() throws {
    // Given
    let expectation = XCTestExpectation(description: self.debugDescription)
    var expectedData: BLEData?
    let mutableCharacteristic = commonMutableCharacteristic()
    let expectedSetNotifyStack: [SetNotifyValueWasCalledStackValue] = [
      SetNotifyValueWasCalledStackValue(enabled: true, characteristic: mutableCharacteristic)
    ]

    // When
    sut.observeValueUpdateAndSetNotification(for: mutableCharacteristic)
      .sink(
        receiveCompletion: { error in
          XCTFail("Observe Value Update and Set Notification should never complete")
        },
        receiveValue: { data in
          expectedData = data
          expectation.fulfill()
        }
      ).store(in: &disposable)
    delegate.didUpdateValueForCharacteristic.send(
      (peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil)
    )

    // Then
    wait(for: [expectation], timeout: 0.005)
    XCTAssertNotNil(expectedData)
    XCTAssertEqual(expectedSetNotifyStack, peripheralMock.setNotifyValueWasCalledStack)
  }

  func testSetNotifyValue() {
    // Given
    let mutableCharacteristic = commonMutableCharacteristic()
    let expectedSetNotifyStack: [SetNotifyValueWasCalledStackValue] = [
      SetNotifyValueWasCalledStackValue(enabled: true, characteristic: mutableCharacteristic)
    ]

    // When
    sut.setNotifyValue(true, for: mutableCharacteristic)

    // Then
    XCTAssertEqual(expectedSetNotifyStack, peripheralMock.setNotifyValueWasCalledStack)
  }

  func testObserveNameValueReturns() {
    // Given
    let expectation = XCTestExpectation(description: self.debugDescription)
    let dataToSend = "Test"
    var expectedData: String?

    // When
    sut.observeNameValue()
      .sink(
        receiveCompletion: { error in
          XCTFail("Observe Name Value should never complete")
        },
        receiveValue: { data in
          expectedData = data
          expectation.fulfill()
        }
      ).store(in: &disposable)
    delegate.didUpdateName.send((peripheral: peripheralMock, name: dataToSend))

    // Then
    wait(for: [expectation], timeout: 0.005)
    XCTAssertEqual(expectedData!, dataToSend)
  }

  func testObserveRSSIValueReturns() {
    // Given
    let expectation = XCTestExpectation(description: self.debugDescription)
    let dataToSend = NSNumber(value: 0)
    var expectedData: NSNumber?

    // When
    sut.observeRSSIValue()
      .sink(
        receiveCompletion: { error in
          XCTFail("Observe RSSI Value should never complete")
        },
        receiveValue: { data in
          expectedData = data
          expectation.fulfill()
        }
      ).store(in: &disposable)
    delegate.didReadRSSI.send((peripheral: peripheralMock, rssi: dataToSend, error: nil))

    // Then
    wait(for: [expectation], timeout: 0.005)
    XCTAssertEqual(expectedData!, dataToSend)
  }

  func testWriteValueWithoutResponseReturnsImmediately() {
    // Given
    let expectation = XCTestExpectation(description: #function)
    let mutableCharacteristic = commonMutableCharacteristic()

    // When
    sut.writeValue(Data(), for: mutableCharacteristic, type: .withoutResponse)
      .sink(
        receiveCompletion: { event in
          expectation.fulfill()
        },
        receiveValue: { result in
        }
      ).store(in: &disposable)

    // Then
    wait(for: [expectation], timeout: 0.005)
    XCTAssertTrue(peripheralMock.writeValueForCharacteristicWasCalled)
  }

  func testWriteValueWithResponseReturnsOnDelegateCall() {
    // Given
    let expectation = XCTestExpectation(description: #function)
    let mutableCharacteristic = commonMutableCharacteristic()

    // When
    sut.writeValue(Data(), for: mutableCharacteristic, type: .withResponse)
      .sink(
        receiveCompletion: { error in
          expectation.fulfill()
        },
        receiveValue: { result in
        }
      ).store(in: &disposable)
    delegate.didWriteValueForCharacteristic.send(
      (peripheral: peripheralMock, characteristic: mutableCharacteristic, error: nil)
    )

    // Then
    wait(for: [expectation], timeout: 0.005)
    XCTAssertTrue(peripheralMock.writeValueForCharacteristicWasCalled)
  }

  func testWriteValueWithResponseReturnsErrorOnDelegateErrorCall() {
    // Given
    let expectation = XCTestExpectation(description: #function)
    let mutableCharacteristic = commonMutableCharacteristic()

    // When
    sut.writeValue(Data(), for: mutableCharacteristic, type: .withResponse)
      .sink(
        receiveCompletion: { completion in
          if case .failure(let error) = completion, case .writeFailed(let subError) = error,
            case .base(code: let code, description: _) = subError,
            code == CBError.Code.connectionFailed
          {
            expectation.fulfill()
          }
        },
        receiveValue: { _ in
        }
      )
      .store(in: &disposable)
    delegate.didWriteValueForCharacteristic.send(
      (
        peripheral: peripheralMock, characteristic: mutableCharacteristic,
        error: NSError(
          domain: CBErrorDomain,
          code: CBError.Code.connectionFailed.rawValue,
          userInfo: nil
        )
      )
    )

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
    sut = StandardBLEPeripheral(
      peripheral: peripheralMock,
      centralManager: centralManager,
      delegate: delegate
    )

    // When
    sut.disconnect()
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .failure(let error):
            if case .peripheral(let e) = error, e == .disconnectionFailed {
              expectation.fulfill()
            }
          case .finished:
            XCTFail("Error should have been returned on completion")
          }
        },
        receiveValue: { _ in }
      )
      .store(in: &disposable)

    // Then
    wait(for: [expectation], timeout: 0.005)
  }

  func testConvenienceInit() {
    // Given
    let peripheralMock = MockCBPeripheralWrapper()

    // When
    sut = StandardBLEPeripheral(peripheral: peripheralMock, centralManager: nil)

    // Then
    XCTAssertNotNil(sut)
  }

  // MARK - Private.

  private func commonMutableCharacteristic(
    type UUID: CBUUID = CBUUID(string: "0x0000"),
    properties: CBCharacteristicProperties = CBCharacteristicProperties(),
    data: Data? = Data(),
    permissions: CBAttributePermissions = CBAttributePermissions()
  ) -> CBMutableCharacteristic {
    return CBMutableCharacteristic(
      type: UUID,
      properties: properties,
      value: data,
      permissions: permissions
    )
  }

}

extension BLEData {
  fileprivate var string: String {
    String(decoding: value, as: UTF8.self)
  }
}
