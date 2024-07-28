//
//  BLEPeripheralManagerTests.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 27/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import XCTest

@testable import BLECombineKit

final class BLEPeripheralManagerTests: XCTestCase {

  var manager: StandardBLEPeripheralManager!
  var managerWrapper: MockCBPeripheralManager!
  var delegate: BLEPeripheralManagerDelegate!
  var cancellables = Set<AnyCancellable>()

  override func setUpWithError() throws {
    managerWrapper = MockCBPeripheralManager(delegate: nil, queue: nil, options: nil)
    delegate = BLEPeripheralManagerDelegate()
    manager = StandardBLEPeripheralManager(peripheralManager: managerWrapper, delegate: delegate)
  }

  override func tearDownWithError() throws {
    manager = nil
    managerWrapper = nil
    delegate = nil
    cancellables.removeAll()
  }

  func testObserveState() {
    // Given.
    let expectation = XCTestExpectation(description: #function)
    let expectedState = CBManagerState.poweredOn
    var receivedState: CBManagerState?

    // When.
    manager.observeState()
      .sink { state in
        receivedState = state
        expectation.fulfill()
      }.store(in: &cancellables)
    delegate.didUpdateState.send(expectedState)

    // Then.
    wait(for: [expectation], timeout: 0.01)
    XCTAssertEqual(receivedState, expectedState)
  }

  func testObserveStateWithInitialValue() {
    // Given.
    let expectation = XCTestExpectation(description: #function)
    let expectedStates: [CBManagerState] = [.poweredOn, .resetting]
    var receivedStates = [CBManagerState]()
    managerWrapper.mutableState = CBManagerState.poweredOn

    // When.
    manager.observeStateWithInitialValue()
      .collect(2)
      .sink { states in
        receivedStates = states
        expectation.fulfill()
      }.store(in: &cancellables)
    delegate.didUpdateState.send(.resetting)

    // Then.
    wait(for: [expectation], timeout: 0.01)
    XCTAssertEqual(receivedStates, expectedStates)
  }

  func testAddService() {
    // Given.
    let expectation = XCTestExpectation(description: #function)
    let uuid = CBUUID(string: "0xFF00")
    let mutableService = CBMutableService(type: uuid, primary: true)
    let expectedAddedServices: [CBService] = [mutableService].map { $0 as CBService }
    var receivedAddedServices = [CBService]()
    managerWrapper.mutableState = .poweredOn

    // When.
    manager.add(mutableService)
      .sink { completion in
        if case .failure(let error) = completion {
          XCTFail("\(#function): \(error)")
        }
        else {
          expectation.fulfill()
        }
      } receiveValue: { service in
        receivedAddedServices.append(service)
      }.store(in: &cancellables)
    delegate.didAddService.send((mutableService, nil))

    // Then.
    wait(for: [expectation], timeout: 0.01)
    XCTAssertEqual(managerWrapper.addServiceStack, expectedAddedServices)
    XCTAssert(receivedAddedServices.isNotEmpty)
    XCTAssertEqual(receivedAddedServices, expectedAddedServices)
  }

  func testRemoveService() {
    // Given.
    let uuid = CBUUID(string: "0xFF00")
    let mutableService = CBMutableService(type: uuid, primary: true)
    let expectedStack: [CBMutableService] = [mutableService]

    // When.
    manager.remove(mutableService)

    // Then.
    XCTAssertEqual(managerWrapper.removeStack, expectedStack)
  }

  func testRemoveAllServices() {
    // Given/When.
    manager.removeAllServices()

    // Then.
    XCTAssertEqual(managerWrapper.removeAllServicesCount, 1)
  }

}
