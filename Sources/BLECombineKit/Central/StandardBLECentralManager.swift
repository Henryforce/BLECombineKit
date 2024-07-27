//
//  StandardBLECentralManager.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 19/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

final class StandardBLECentralManager: BLECentralManager {
  /// The wrapped CBCentralManager.
  let associatedCentralManager: CBCentralManagerWrapper

  /// The provider of BLEPeripherals.
  lazy var peripheralProvider: BLEPeripheralProvider = StandardBLEPeripheralProvider(
    centralManager: self
  )

  /// The Publisher used for tracking the latest state of the wrapped manager.
  private(set) var stateSubject = CurrentValueSubject<CBManagerState, Never>(CBManagerState.unknown)

  /// The delegate to listen to for events.
  let delegate: BLECentralManagerDelegate

  /// The Set used to track all cancellables.
  private var cancellables = Set<AnyCancellable>()

  var isScanning: Bool {
    associatedCentralManager.isScanning
  }

  /// The getter for the state subject.
  var state: AnyPublisher<CBManagerState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  init(
    centralManager: CBCentralManagerWrapper,
    managerDelegate: BLECentralManagerDelegate = BLECentralManagerDelegate()
  ) {
    self.associatedCentralManager = centralManager
    self.delegate = managerDelegate

    centralManager.setupDelegate(managerDelegate)
    subscribeToDelegate()
  }

  convenience init(with centralManager: CBCentralManager) {
    self.init(centralManager: centralManager, managerDelegate: BLECentralManagerDelegate())
  }

  func retrievePeripherals(
    withIdentifiers identifiers: [UUID]
  ) -> AnyPublisher<BLEPeripheral, BLEError> {
    let retrievedPeripherals = associatedCentralManager.retrieveCBPeripherals(
      withIdentifiers: identifiers
    )
    return observePeripherals(from: retrievedPeripherals)
  }

  func retrieveConnectedPeripherals(
    withServices serviceUUIDs: [CBUUID]
  ) -> AnyPublisher<BLEPeripheral, BLEError> {
    let retrievedPeripherals = associatedCentralManager.retrieveConnectedCBPeripherals(
      withServices: serviceUUIDs
    )
    return observePeripherals(from: retrievedPeripherals)
  }

  func scanForPeripherals(
    withServices services: [CBUUID]?,
    options: [String: Any]?
  ) -> AnyPublisher<BLEScanResult, BLEError> {
    let provider = peripheralProvider
    let stream = delegate
      .didDiscoverAdvertisementData
      .map { result -> BLEScanResult in
        let peripheral = provider.provide(for: result.peripheral)
        return BLEScanResult(
          peripheral: peripheral,
          advertisementData: result.advertisementData,
          rssi: result.rssi
        )
      }
      .eraseToAnyPublisher()

    return Deferred<AnyPublisher<BLEScanResult, BLEError>> { [associatedCentralManager] in
      defer {
        associatedCentralManager.scanForPeripherals(withServices: services, options: options)
      }
      return stream
    }.eraseToAnyPublisher()
  }

  func stopScan() {
    associatedCentralManager.stopScan()
  }

  func connect(
    peripheral: BLEPeripheral,
    options: [String: Any]?
  ) -> AnyPublisher<BLEPeripheral, BLEError> {
    let provider = peripheralProvider
    defer {
      associatedCentralManager.connect(peripheral.associatedPeripheral, options: options)
    }

    // TODO: merge with didFailToConnect.
    // TODO: make sure the wrapped peripheral has the same ID as the given peripheral to connect.
    return delegate
      .didConnectPeripheral
      .map { provider.provide(for: $0) }
      .eraseToAnyPublisher()
  }

  func cancelPeripheralConnection(
    _ peripheral: BLEPeripheral
  ) -> AnyPublisher<Never, Never> {
    let associatedPeripheral = peripheral.associatedPeripheral
    defer {
      associatedCentralManager.cancelPeripheralConnection(associatedPeripheral)
    }

    return delegate
      .didDisconnectPeripheral
      .first { $0.identifier == associatedPeripheral.identifier }
      .ignoreOutput()
      .ignoreFailure()
      .eraseToAnyPublisher()
  }

  #if os(iOS) || os(tvOS) || os(watchOS)
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?) {
      associatedCentralManager.registerForConnectionEvents(options: options)
    }
  #endif

  func observeWillRestoreState() -> AnyPublisher<[String: Any], Never> {
    delegate.willRestoreState.eraseToAnyPublisher()
  }

  func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never> {
    let provider = peripheralProvider
    return delegate.didUpdateANCSAuthorization
      .map { provider.provide(for: $0) }
      .eraseToAnyPublisher()
  }

  // MARK: - Private methods

  private func subscribeToDelegate() {
    observeUpdateState()
    observeDidConnectPeripheral()
    observeDidFailToConnectPeripheral()
    observeDidDisconnectPeripheral()
  }

  private func observeUpdateState() {
    let stateSubject = self.stateSubject
    return delegate
      .didUpdateState
      .sink { stateSubject.send($0) }
      .store(in: &cancellables)
  }

  private func observeDidConnectPeripheral() {
    delegate
      .didConnectPeripheral
      .ignoreFailure()
      .sink { [peripheralProvider] result in
        peripheralProvider
          .provide(for: result)
          .connectionState.send(true)
      }.store(in: &cancellables)
  }

  private func observeDidFailToConnectPeripheral() {
    delegate
      .didFailToConnect
      .ignoreFailure()
      .sink { [peripheralProvider] result in
        peripheralProvider.provide(for: result)
          .connectionState.send(false)
      }.store(in: &cancellables)
  }

  private func observeDidDisconnectPeripheral() {
    delegate
      .didDisconnectPeripheral
      .sink { [peripheralProvider] result in
        peripheralProvider.provide(for: result)
          .connectionState.send(false)
      }.store(in: &cancellables)
  }

  private func observePeripherals(
    from retrievedPeripherals: [CBPeripheralWrapper]
  ) -> AnyPublisher<BLEPeripheral, BLEError> {
    let provider = peripheralProvider
    let peripherals =
      retrievedPeripherals
      .map { provider.provide(for: $0) }

    return Publishers.Sequence.init(sequence: peripherals)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

}
