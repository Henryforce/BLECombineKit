//
//  MockCBCentralManagerWrapper.swift
//  BLECombineKitMocks
//
//  Created by Henry Javier Serrano Echeverria on 10/1/26.
//

import BLECombineKit
import CoreBluetooth
import Foundation

/// A mock implementation of `CBCentralManagerWrapper` for testing purposes.
open class MockCBCentralManagerWrapper: CBCentralManagerWrapper, @unchecked Sendable {

  public init() {}

  /// The wrapped `CBCentralManager`.
  public var wrappedManager: CBCentralManager?

  /// Flag to control the `isScanning` property.
  public var isScanningValue: Bool = false
  public var isScanning: Bool {
    isScanningValue
  }

  /// The delegate for the central manager.
  public var delegate: CBCentralManagerDelegate?

  /// Count of how many times `setupDelegate(_:)` was called.
  public var setupDelegateWasCalledCount = 0
  /// The delegate passed to the last call of `setupDelegate(_:)`.
  public var setupDelegateDelegate: CBCentralManagerDelegate?

  /// Mocks setting up the delegate.
  public func setupDelegate(_ delegate: CBCentralManagerDelegate) {
    setupDelegateWasCalledCount += 1
    setupDelegateDelegate = delegate
    self.delegate = delegate
  }

  /// Return value for `retrieveCBPeripherals(withIdentifiers:)`.
  public var retrieveCBPeripheralsReturnValue: [CBPeripheralWrapper] = []
  /// Count of how many times `retrieveCBPeripherals(withIdentifiers:)` was called.
  public var retrieveCBPeripheralsWasCalledCount = 0
  /// The identifiers passed to the last call of `retrieveCBPeripherals(withIdentifiers:)`.
  public var retrieveCBPeripheralsIdentifiers = [UUID]()

  /// Mocks retrieving peripherals with specified identifiers.
  public func retrieveCBPeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper] {
    retrieveCBPeripheralsWasCalledCount += 1
    retrieveCBPeripheralsIdentifiers = identifiers
    return retrieveCBPeripheralsReturnValue
  }

  /// Return value for `retrieveConnectedCBPeripherals(withServices:)`.
  public var retrieveConnectedCBPeripheralsReturnValue: [CBPeripheralWrapper] = []
  /// Count of how many times `retrieveConnectedCBPeripherals(withServices:)` was called.
  public var retrieveConnectedCBPeripheralsWasCalledCount = 0
  /// The service UUIDs passed to the last call of `retrieveConnectedCBPeripherals(withServices:)`.
  public var retrieveConnectedCBPeripheralsServiceUUIDs = [CBUUID]()

  /// Mocks retrieving connected peripherals with specified service UUIDs.
  public func retrieveConnectedCBPeripherals(withServices serviceUUIDs: [CBUUID])
    -> [CBPeripheralWrapper]
  {
    retrieveConnectedCBPeripheralsWasCalledCount += 1
    retrieveConnectedCBPeripheralsServiceUUIDs = serviceUUIDs
    return retrieveConnectedCBPeripheralsReturnValue
  }

  /// Count of how many times `scanForPeripherals(withServices:options:)` was called.
  public var scanForPeripheralsWasCalledCount = 0
  /// The service UUIDs passed to the last call of `scanForPeripherals(withServices:options:)`.
  public var scanForPeripheralsServiceUUIDs: [CBUUID]?
  /// The options passed to the last call of `scanForPeripherals(withServices:options:)`.
  public var scanForPeripheralsOptions: [String: Any]?

  /// Mocks scanning for peripherals.
  public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?) {
    scanForPeripheralsWasCalledCount += 1
    scanForPeripheralsServiceUUIDs = serviceUUIDs
    scanForPeripheralsOptions = options
  }

  /// Count of how many times `stopScan()` was called.
  public var stopScanWasCalledCount = 0

  /// Mocks stopping the peripheral scan.
  public func stopScan() {
    stopScanWasCalledCount += 1
  }

  /// Count of how many times `connect(_:options:)` was called.
  public var connectWasCalledCount = 0
  /// The peripheral passed to the last call of `connect(_:options:)`.
  public var connectPeripheral: CBPeripheralWrapper?
  /// The options passed to the last call of `connect(_:options:)`.
  public var connectOptions: [String: Any]?

  /// Mocks connecting to a peripheral.
  public func connect(_ wrappedPeripheral: CBPeripheralWrapper, options: [String: Any]?) {
    connectWasCalledCount += 1
    connectPeripheral = wrappedPeripheral
    connectOptions = options
  }

  /// Count of how many times `cancelPeripheralConnection(_:)` was called.
  public var cancelPeripheralConnectionWasCalledCount = 0
  /// The peripheral passed to the last call of `cancelPeripheralConnection(_:)`.
  public var cancelPeripheralConnectionPeripheral: CBPeripheralWrapper?

  /// Mocks cancelling a peripheral connection.
  public func cancelPeripheralConnection(_ wrappedPeripheral: CBPeripheralWrapper) {
    cancelPeripheralConnectionWasCalledCount += 1
    cancelPeripheralConnectionPeripheral = wrappedPeripheral
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
}
