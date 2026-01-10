//
//  MockBLECentralManager.swift
//  BLECombineKitMocks
//
//  Created by Henry Javier Serrano Echeverria on 10/1/26.
//

import BLECombineKit
import Combine
import CoreBluetooth
import Foundation

/// A mock implementation of `BLECentralManager` for testing purposes.
open class MockBLECentralManager: BLECentralManager, @unchecked Sendable {

  public init() {}

  /// Subject to control the state of the central manager.
  public var stateSubject = CurrentValueSubject<CBManagerState, Never>(.unknown)

  /// Publisher for the state of the central manager.
  public var state: AnyPublisher<CBManagerState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  /// The associated central manager wrapper.
  public var associatedCentralManager: CBCentralManagerWrapper = MockCBCentralManagerWrapper()

  /// Flag to control the `isScanning` property.
  public var isScanningValue: Bool = false
  public var isScanning: Bool {
    isScanningValue
  }

  /// Return value for `retrievePeripherals(withIdentifiers:)`.
  public var retrievePeripheralsReturnValue: AnyPublisher<BLEPeripheral, BLEError> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `retrievePeripherals(withIdentifiers:)` was called.
  public var retrievePeripheralsWasCalledCount = 0
  /// The identifiers passed to the last call of `retrievePeripherals(withIdentifiers:)`.
  public var retrievePeripheralsIdentifiers = [UUID]()

  /// Mocks the retrieval of peripherals with specified identifiers.
  public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<
    BLEPeripheral, BLEError
  > {
    retrievePeripheralsWasCalledCount += 1
    retrievePeripheralsIdentifiers = identifiers
    return retrievePeripheralsReturnValue
  }

  /// Return value for `retrieveConnectedPeripherals(withServices:)`.
  public var retrieveConnectedPeripheralsReturnValue: AnyPublisher<BLEPeripheral, BLEError> =
    Empty().eraseToAnyPublisher()
  /// Count of how many times `retrieveConnectedPeripherals(withServices:)` was called.
  public var retrieveConnectedPeripheralsWasCalledCount = 0
  /// The service UUIDs passed to the last call of `retrieveConnectedPeripherals(withServices:)`.
  public var retrieveConnectedPeripheralsServiceUUIDs = [CBUUID]()

  /// Mocks the retrieval of connected peripherals with specified service UUIDs.
  public func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<
    BLEPeripheral, BLEError
  > {
    retrieveConnectedPeripheralsWasCalledCount += 1
    retrieveConnectedPeripheralsServiceUUIDs = serviceUUIDs
    return retrieveConnectedPeripheralsReturnValue
  }

  /// Return value for `scanForPeripherals(withServices:options:)`.
  public var scanForPeripheralsReturnValue: AnyPublisher<BLEScanResult, BLEError> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `scanForPeripherals(withServices:options:)` was called.
  public var scanForPeripheralsWasCalledCount = 0
  /// The services passed to the last call of `scanForPeripherals(withServices:options:)`.
  public var scanForPeripheralsServices: [CBUUID]?
  /// The options passed to the last call of `scanForPeripherals(withServices:options:)`.
  public var scanForPeripheralsOptions: [String: Any]?

  /// Mocks scanning for peripherals.
  public func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?)
    -> AnyPublisher<BLEScanResult, BLEError>
  {
    scanForPeripheralsWasCalledCount += 1
    scanForPeripheralsServices = services
    scanForPeripheralsOptions = options
    return scanForPeripheralsReturnValue
  }

  /// Count of how many times `stopScan()` was called.
  public var stopScanWasCalledCount = 0

  /// Mocks stopping the peripheral scan.
  public func stopScan() {
    stopScanWasCalledCount += 1
  }

  /// Return value for `connect(peripheral:options:)`.
  public var connectReturnValue: AnyPublisher<BLEPeripheral, BLEError> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `connect(peripheral:options:)` was called.
  public var connectWasCalledCount = 0
  /// The peripheral passed to the last call of `connect(peripheral:options:)`.
  public var connectPeripheral: BLEPeripheral?
  /// The options passed to the last call of `connect(peripheral:options:)`.
  public var connectOptions: [String: Any]?

  /// Mocks connecting to a peripheral.
  public func connect(peripheral: BLEPeripheral, options: [String: Any]?) -> AnyPublisher<
    BLEPeripheral, BLEError
  > {
    connectWasCalledCount += 1
    connectPeripheral = peripheral
    connectOptions = options
    return connectReturnValue
  }

  /// Return value for `cancelPeripheralConnection(_:)`.
  public var cancelPeripheralConnectionReturnValue: AnyPublisher<Never, Never> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `cancelPeripheralConnection(_:)` was called.
  public var cancelPeripheralConnectionWasCalledCount = 0
  /// The peripheral passed to the last call of `cancelPeripheralConnection(_:)`.
  public var cancelPeripheralConnectionPeripheral: BLEPeripheral?

  /// Mocks cancelling a peripheral connection.
  public func cancelPeripheralConnection(_ peripheral: BLEPeripheral) -> AnyPublisher<Never, Never>
  {
    cancelPeripheralConnectionWasCalledCount += 1
    cancelPeripheralConnectionPeripheral = peripheral
    return cancelPeripheralConnectionReturnValue
  }

  /// Count of how many times `registerForConnectionEvents(options:)` was called.
  public var registerForConnectionEventsWasCalledCount = 0
  /// The options passed to the last call of `registerForConnectionEvents(options:)`.
  public var registerForConnectionEventsOptions: [CBConnectionEventMatchingOption: Any]?

  /// Mocks registering for connection events.
  public func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?) {
    registerForConnectionEventsWasCalledCount += 1
    registerForConnectionEventsOptions = options
  }

  /// Return value for `observeWillRestoreState()`.
  public var observeWillRestoreStateReturnValue: AnyPublisher<[String: Any], Never> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `observeWillRestoreState()` was called.
  public var observeWillRestoreStateWasCalledCount = 0

  /// Mocks observing state restoration.
  public func observeWillRestoreState() -> AnyPublisher<[String: Any], Never> {
    observeWillRestoreStateWasCalledCount += 1
    return observeWillRestoreStateReturnValue
  }

  /// Return value for `observeDidUpdateANCSAuthorization()`.
  public var observeDidUpdateANCSAuthorizationReturnValue: AnyPublisher<BLEPeripheral, Never> =
    Empty().eraseToAnyPublisher()
  /// Count of how many times `observeDidUpdateANCSAuthorization()` was called.
  public var observeDidUpdateANCSAuthorizationWasCalledCount = 0

  /// Mocks observing ANCS authorization updates.
  public func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never> {
    observeDidUpdateANCSAuthorizationWasCalledCount += 1
    return observeDidUpdateANCSAuthorizationReturnValue
  }
}
