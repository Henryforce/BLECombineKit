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

  let associatedCentralManager: CBCentralManagerWrapper
  let peripheralProvider: BLEPeripheralProvider

  var stateSubject = CurrentValueSubject<ManagerState, Never>(ManagerState.unknown)
  let delegate: BLECentralManagerDelegate

  private var cancellables = Set<AnyCancellable>()

  var isScanning: Bool {
    associatedCentralManager.isScanning
  }

  var state: AnyPublisher<ManagerState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  init(
    centralManager: CBCentralManagerWrapper,
    managerDelegate: BLECentralManagerDelegate = BLECentralManagerDelegate(),
    peripheralProvider: BLEPeripheralProvider = StandardBLEPeripheralProvider()
  ) {
    self.associatedCentralManager = centralManager
    self.delegate = managerDelegate
    self.peripheralProvider = peripheralProvider

    if let centralManager = centralManager as? StandardCBCentralManagerWrapper {
      centralManager.setupDelegate(managerDelegate)
    }

    subscribeToDelegate()
  }

  convenience init(with centralManager: CBCentralManager) {
    let centralManagerWrapper = StandardCBCentralManagerWrapper(with: centralManager)
    self.init(centralManager: centralManagerWrapper, managerDelegate: BLECentralManagerDelegate())
  }

  func retrievePeripherals(
    withIdentifiers identifiers: [UUID]
  ) -> AnyPublisher<BLEPeripheral, BLEError> {
    let retrievedPeripherals = associatedCentralManager.retrievePeripherals(
      withIdentifiers: identifiers
    )
    return observePeripherals(from: retrievedPeripherals)
  }

  func retrieveConnectedPeripherals(
    withServices serviceUUIDs: [CBUUID]
  ) -> AnyPublisher<BLEPeripheral, BLEError> {
    let retrievedPeripherals = associatedCentralManager.retrieveConnectedPeripherals(
      withServices: serviceUUIDs
    )
    return observePeripherals(from: retrievedPeripherals)
  }

  func scanForPeripherals(
    withServices services: [CBUUID]?,
    options: [String: Any]?
  ) -> AnyPublisher<BLEScanResult, BLEError> {
    let stream = delegate
      .didDiscoverAdvertisementData
      .eraseToAnyPublisher()  // Erase needed to silence flatMap(maxPublishers) availability.
      .flatMap { [weak self] result -> AnyPublisher<BLEScanResult, BLEError> in
        guard let self else { return Fail(error: BLEError.deallocated).eraseToAnyPublisher() }
        let peripheral = self.peripheralProvider.provide(
          for: result.peripheral,
          centralManager: self
        )
        return Just(
          BLEScanResult(
            peripheral: peripheral,
            advertisementData: result.advertisementData,
            rssi: result.rssi
          )
        ).setFailureType(to: BLEError.self).eraseToAnyPublisher()
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
    associatedCentralManager.connect(peripheral.associatedPeripheral, options: options)

    // TODO: merge with didFailToConnect.
    // TODO: make sure the wrapped peripheral has the same ID as the given peripheral to connect.
    return delegate
      .didConnectPeripheral
      .setFailureType(to: BLEError.self)
      .tryMap { [weak self] wrappedPeripheral in
        guard let self else { throw BLEError.deallocated }
        let peripheral = self.peripheralProvider.provide(
          for: wrappedPeripheral,
          centralManager: self
        )
        return peripheral
      }
      .mapError { $0 as? BLEError ?? BLEError.unknown }
      .eraseToAnyPublisher()
  }

  func cancelPeripheralConnection(
    _ peripheral: BLEPeripheral
  ) -> AnyPublisher<Never, Never> {
    let associatedPeripheral = peripheral.associatedPeripheral
    associatedCentralManager.cancelPeripheralConnection(associatedPeripheral)

    return delegate
      .didDisconnectPeripheral
      .filter { $0.identifier == associatedPeripheral.identifier }
      .first()
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
    delegate.didUpdateANCSAuthorization
      .compactMap { [weak self] peripheral in
        guard let self = self else { return nil }
        return self.peripheralProvider.provide(for: peripheral, centralManager: self)
      }.eraseToAnyPublisher()
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
      .sink { [weak self] result in
        guard let self = self else { return }
        self.peripheralProvider
          .provide(for: result, centralManager: self)
          .connectionState.send(true)
      }.store(in: &cancellables)
  }

  private func observeDidFailToConnectPeripheral() {
    delegate
      .didFailToConnect
      .ignoreFailure()
      .sink { [weak self] result in
        guard let self = self else { return }
        self.peripheralProvider.provide(for: result, centralManager: self).connectionState.send(
          false
        )
      }.store(in: &cancellables)
  }

  private func observeDidDisconnectPeripheral() {
    delegate
      .didDisconnectPeripheral
      .sink { [weak self] result in
        guard let self = self else { return }
        self.peripheralProvider.provide(for: result, centralManager: self).connectionState.send(
          false
        )
      }.store(in: &cancellables)
  }

  private func observePeripherals(
    from retrievedPeripherals: [CBPeripheralWrapper]
  ) -> AnyPublisher<BLEPeripheral, BLEError> {
    let peripherals =
      retrievedPeripherals
      .compactMap { [weak self] peripheral -> BLEPeripheral? in
        guard let self = self else { return nil }
        return self.peripheralProvider.provide(
          for: peripheral,
          centralManager: self
        )
      }

    return Publishers.Sequence.init(sequence: peripherals)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

}
