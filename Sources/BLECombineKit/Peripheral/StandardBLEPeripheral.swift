//
//  StandardBLEPeripheral.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 6/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth

final class StandardBLEPeripheral: BLETrackedPeripheral {

  /// Subject used for tracking the lateset connection state.
  let connectionState = CurrentValueSubject<Bool, Never>(false)

  /// Wrapper for the CBPeripheral associated to this class.
  public let associatedPeripheral: CBPeripheralWrapper

  /// Reference to the wrapper delegate used for tracking BLE events.
  private let delegate: BLEPeripheralDelegate

  /// Reference to te BLECentralManager.
  private weak var centralManager: BLECentralManager?

  /// Cancellable reference to the connect publisher.
  private var connectCancellable: AnyCancellable?

  private typealias CharacteristicValuePreHandler = () -> (Void)

  init(
    peripheral: CBPeripheralWrapper,
    centralManager: BLECentralManager?,
    delegate: BLEPeripheralDelegate
  ) {
    self.associatedPeripheral = peripheral
    self.centralManager = centralManager
    self.delegate = delegate
  }

  func observeConnectionState() -> AnyPublisher<Bool, Never> {
    return connectionState.eraseToAnyPublisher()
  }

  func connect(
    with options: [String: Any]?
  ) -> AnyPublisher<BLEPeripheral, BLEError> {
    return Future<BLEPeripheral, BLEError> { [weak self] promise in
      guard let self else {
        promise(.failure(BLEError.deallocated))
        return
      }
      self.connectCancellable?.cancel()

      let makeDisconnected: AnyPublisher<Never, Never> =
        if self.connectionState.value {
          self.disconnect().ignoreFailure()
        }
        else {
          Empty().eraseToAnyPublisher()
        }

      // Independent of the connection status, the makeDisconnected publisher will
      // trigger a completion on the first part of the stream below. The handleEvents'
      // receiveCompletion will then be triggered to connect to the peripheral.
      // The call to append will then start publishing the latest connectionState.
      connectCancellable =
        makeDisconnected
        .handleEvents(
          receiveCompletion: { [weak self] _ in
            guard let self, let manager = self.centralManager else { return }
            let peripheral = self.associatedPeripheral
            manager.associatedCentralManager.connect(peripheral, options: options)
          }
        )
        .setOutputType(to: Bool.self)
        .append(connectionState.dropFirst().first())
        .sink { [weak self] successfullyConnected in
          if let self, successfullyConnected {
            promise(.success(self))
          }
          else {
            promise(.failure(BLEError.peripheral(.connectionFailure)))
          }
        }
    }.eraseToAnyPublisher()
  }

  @discardableResult
  func disconnect() -> AnyPublisher<Never, BLEError> {
    guard let centralManager = centralManager else {
      return Fail(error: BLEError.peripheral(.disconnectionFailed))
        .eraseToAnyPublisher()
    }
    return
      centralManager
      .cancelPeripheralConnection(self)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  func observeNameValue() -> AnyPublisher<String, Never> {
    return delegate
      .didUpdateName
      .map { $0.name }
      .eraseToAnyPublisher()
  }

  func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
    Deferred<AnyPublisher<NSNumber, BLEError>> { [delegate, associatedPeripheral] in
      defer {
        associatedPeripheral.readRSSI()
      }
      return delegate
        .didReadRSSI
        .map { $0.rssi }
        .eraseToAnyPublisher()
    }.eraseToAnyPublisher()
  }

  func discoverServices(
    serviceUUIDs: [CBUUID]?
  ) -> AnyPublisher<BLEService, BLEError> {
    if let services = associatedPeripheral.services, services.isNotEmpty {
      return Publishers.Sequence(sequence: services)
        .setFailureType(to: BLEError.self)
        .map { BLEService(value: $0, peripheral: self) }
        .eraseToAnyPublisher()
    }

    return Deferred<AnyPublisher<BLEService, BLEError>> {
      [weak self, delegate, associatedPeripheral] in
      defer {
        associatedPeripheral.discoverServices(serviceUUIDs)
      }
      let identifier = associatedPeripheral.identifier
      return delegate
        .didDiscoverServices
        .filter { $0.peripheral.identifier == identifier }
        .first()
        .flatMap { result -> AnyPublisher<CBService, BLEError> in
          let output = result.peripheral.services ?? []
          return Publishers.Sequence(sequence: output)
            .eraseToAnyPublisher()
        }
        .compactMap { [weak self] output -> BLEService? in
          guard let self else { return nil }
          return BLEService(value: output, peripheral: self)
        }
        .eraseToAnyPublisher()
    }.eraseToAnyPublisher()
  }

  func discoverCharacteristics(
    characteristicUUIDs: [CBUUID]?,
    for service: CBService
  ) -> AnyPublisher<BLECharacteristic, BLEError> {
    return Deferred<AnyPublisher<BLECharacteristic, BLEError>> {
      [weak self, delegate, associatedPeripheral] in
      defer {
        associatedPeripheral.discoverCharacteristics(characteristicUUIDs, for: service)
      }
      let identifier = associatedPeripheral.identifier
      return delegate
        .didDiscoverCharacteristics
        .filter { $0.peripheral.identifier == identifier }
        .first()
        .flatMap { result -> AnyPublisher<CBCharacteristic, BLEError> in
          let output = result.service.characteristics ?? []
          return Publishers.Sequence(sequence: output)
            .eraseToAnyPublisher()
        }
        .compactMap { [weak self] output -> BLECharacteristic? in
          guard let self else { return nil }
          return BLECharacteristic(value: output, peripheral: self)
        }
        .eraseToAnyPublisher()
    }.eraseToAnyPublisher()
  }

  func observeValue(
    for characteristic: CBCharacteristic
  ) -> AnyPublisher<BLEData, BLEError> {
    return buildDeferredValuePublisher(for: characteristic, preHandler: nil)
      .eraseToAnyPublisher()
  }

  func readValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
    let preHandler: () -> (Void) = { [weak self] in
      self?.associatedPeripheral.readValue(for: characteristic)
    }
    return buildDeferredValuePublisher(for: characteristic, preHandler: preHandler)
      .first()
      .eraseToAnyPublisher()
  }

  func observeValueUpdateAndSetNotification(
    for characteristic: CBCharacteristic
  ) -> AnyPublisher<BLEData, BLEError> {
    let preHandler: () -> (Void) = { [weak self] in
      self?.associatedPeripheral.setNotifyValue(true, for: characteristic)
    }
    return buildDeferredValuePublisher(for: characteristic, preHandler: preHandler)
      .eraseToAnyPublisher()
  }

  func setNotifyValue(
    _ enabled: Bool,
    for characteristic: CBCharacteristic
  ) {
    associatedPeripheral.setNotifyValue(enabled, for: characteristic)
  }

  func writeValue(
    _ data: Data,
    for characteristic: CBCharacteristic,
    type: CBCharacteristicWriteType
  ) -> AnyPublisher<Never, BLEError> {
    return Deferred<AnyPublisher<Never, BLEError>> { [delegate, associatedPeripheral] in
      defer {
        associatedPeripheral.writeValue(data, for: characteristic, type: type)
      }
      switch type {
      case .withResponse:
        return delegate
          .didWriteValueForCharacteristic
          .filter({ $0.characteristic.uuid == characteristic.uuid })
          .flatMap { result -> AnyPublisher<Bool, BLEError> in
            BLECombineKit.OutputOrFail(output: true, error: result.error)
          }
          .first()
          .ignoreOutput()
          .eraseToAnyPublisher()
      default:
        return Empty(completeImmediately: true)
          .setFailureType(to: BLEError.self)
          .eraseToAnyPublisher()
      }
    }.eraseToAnyPublisher()
  }

  // MARK - Private.

  private func buildDeferredValuePublisher(
    for characteristic: CBCharacteristic,
    preHandler: CharacteristicValuePreHandler?
  ) -> AnyPublisher<BLEData, BLEError> {
    return Deferred<AnyPublisher<BLEData, BLEError>> { [delegate] in
      // Run the pre-handler to run the method that will trigger the delegate's publisher.
      defer { preHandler?() }
      return delegate
        .didUpdateValueForCharacteristic
        .filter { $0.characteristic.uuid == characteristic.uuid }
        .flatMap { filteredPeripheral -> AnyPublisher<BLEData, BLEError> in
          guard let data = filteredPeripheral.characteristic.value else {
            return Fail(error: BLEError.data(.invalid)).eraseToAnyPublisher()
          }
          return BLECombineKit.Just(BLEData(value: data))
        }
        .eraseToAnyPublisher()
    }.eraseToAnyPublisher()
  }

}
