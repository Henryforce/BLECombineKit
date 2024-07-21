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

  /// Cancellable reference to the discoverServices publisher.
  private var discoverServicesCancellable: AnyCancellable?

  /// Cancellable reference to the discoverCharacteristics publisher.
  private var discoverCharacteristicsCancellable: AnyCancellable?

  init(
    peripheral: CBPeripheralWrapper,
    centralManager: BLECentralManager?,
    delegate: BLEPeripheralDelegate
  ) {
    self.associatedPeripheral = peripheral
    self.centralManager = centralManager
    self.delegate = delegate
  }

  public convenience init(
    peripheral: CBPeripheralWrapper,
    centralManager: BLECentralManager?
  ) {
    let delegate = BLEPeripheralDelegate()
    if let peripheral = peripheral as? StandardCBPeripheralWrapper {
      peripheral.setupDelegate(delegate)
    }
    self.init(peripheral: peripheral, centralManager: centralManager, delegate: delegate)
  }

  public func observeConnectionState() -> AnyPublisher<Bool, Never> {
    return connectionState.eraseToAnyPublisher()
  }

  public func connect(
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
  public func disconnect() -> AnyPublisher<Never, BLEError> {
    guard let centralManager = centralManager else {
      return Just(false)
        .tryMap { _ in throw BLEError.peripheral(.disconnectionFailed) }
        .mapError { $0 as? BLEError ?? BLEError.unknown }
        .eraseToAnyPublisher()
    }
    return
      centralManager
      .cancelPeripheralConnection(self)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  public func observeNameValue() -> AnyPublisher<String, Never> {
    return delegate
      .didUpdateName
      .map { $0.name }
      .eraseToAnyPublisher()
  }

  public func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
    associatedPeripheral.readRSSI()

    return delegate
      .didReadRSSI
      .map { $0.rssi }
      .mapError { $0 as? BLEError ?? BLEError.unknown }
      .eraseToAnyPublisher()
  }

  public func discoverServices(
    serviceUUIDs: [CBUUID]?
  ) -> AnyPublisher<BLEService, BLEError> {
    let subject = PassthroughSubject<BLEService, BLEError>()

    if let services = associatedPeripheral.services, services.isNotEmpty {
      return Publishers.Sequence(sequence: services)
        .setFailureType(to: BLEError.self)
        .map { BLEService(value: $0, peripheral: self) }
        .eraseToAnyPublisher()
    }

    associatedPeripheral.discoverServices(serviceUUIDs)
    discoverServicesCancellable?.cancel()

    discoverServicesCancellable = delegate
      .didDiscoverServices
      .tryFilter { [weak self] in
        guard let self = self else { throw BLEError.deallocated }
        return $0.peripheral.identifier == self.associatedPeripheral.identifier
      }
      .tryMap { result -> [CBService] in
        guard result.error == nil, let services = result.peripheral.services else {
          throw BLEError.peripheral(
            .servicesFoundError(BLEError.CoreBluetoothError.from(error: result.error! as NSError))
          )
        }
        return services
      }
      .mapError { $0 as? BLEError ?? BLEError.unknown }
      .sink(
        receiveCompletion: { completion in
          guard case .failure(let error) = completion else { return }
          subject.send(completion: .failure(error))
        },
        receiveValue: { [weak self] services in
          guard let self = self else { return }
          services.forEach { service in
            subject.send(BLEService(value: service, peripheral: self))
          }
          subject.send(completion: .finished)
        }
      )

    return subject.eraseToAnyPublisher()
  }

  public func discoverCharacteristics(
    characteristicUUIDs: [CBUUID]?,
    for service: CBService
  ) -> AnyPublisher<BLECharacteristic, BLEError> {
    let subject = PassthroughSubject<BLECharacteristic, BLEError>()
    discoverCharacteristicsCancellable?.cancel()

    discoverCharacteristicsCancellable = delegate
      .didDiscoverCharacteristics
      .handleEvents(receiveSubscription: { [weak self] _ in
        self?.associatedPeripheral.discoverCharacteristics(characteristicUUIDs, for: service)
      })
      .tryFilter { [weak self] in
        guard let self = self else { throw BLEError.deallocated }
        return $0.peripheral.identifier == self.associatedPeripheral.identifier
      }
      .tryMap { result -> [CBCharacteristic] in
        guard result.error == nil, let characteristics = result.service.characteristics else {
          throw BLEError.peripheral(
            .characteristicsFoundError(
              BLEError.CoreBluetoothError.from(error: result.error! as NSError)
            )
          )
        }
        return characteristics
      }
      .mapError { $0 as? BLEError ?? BLEError.unknown }
      .sink(
        receiveCompletion: { completion in
          guard case .failure(let error) = completion else { return }
          subject.send(completion: .failure(error))
        },
        receiveValue: { [weak self] characteristics in
          guard let self = self else { return }
          characteristics.forEach { characteristic in
            subject.send(BLECharacteristic(value: characteristic, peripheral: self))
          }
          subject.send(completion: .finished)
        }
      )

    return subject.eraseToAnyPublisher()
  }

  public func observeValue(
    for characteristic: CBCharacteristic
  ) -> AnyPublisher<BLEData, BLEError> {
    buildDeferredValuePublisher(for: characteristic)
      .handleEvents(receiveRequest: { [weak self] _ in
        self?.associatedPeripheral.readValue(for: characteristic)
      }).eraseToAnyPublisher()
  }

  public func readValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
    buildDeferredValuePublisher(for: characteristic)
      .first()
      .handleEvents(receiveSubscription: { [weak self] _ in
        self?.associatedPeripheral.readValue(for: characteristic)
      }).eraseToAnyPublisher()
  }

  public func observeValueUpdateAndSetNotification(
    for characteristic: CBCharacteristic
  ) -> AnyPublisher<BLEData, BLEError> {
    //    buildDeferredValuePublisher(for: characteristic)
    //      .handleEvents(receiveRequest: { [weak self] _ in
    //        self?.associatedPeripheral.setNotifyValue(true, for: characteristic)
    //      }).eraseToAnyPublisher()

    let deferredPublisher = buildDeferredValuePublisher(for: characteristic)
    return delegate.didUpdateNotificationState
      .handleEvents(receiveRequest: { [weak self] _ in
        self?.associatedPeripheral.setNotifyValue(true, for: characteristic)
      })
      .filter { $0.characteristic.uuid == characteristic.uuid }
      .flatMap { output -> AnyPublisher<BLEData, BLEError> in
        if let error = output.error {
          return Fail(error: error).eraseToAnyPublisher()
        }
        return deferredPublisher
      }
      .eraseToAnyPublisher()
  }

  public func setNotifyValue(
    _ enabled: Bool,
    for characteristic: CBCharacteristic
  ) {
    associatedPeripheral.setNotifyValue(enabled, for: characteristic)
  }

  public func writeValue(
    _ data: Data,
    for characteristic: CBCharacteristic,
    type: CBCharacteristicWriteType
  ) -> AnyPublisher<Never, BLEError> {
    defer {
      associatedPeripheral.writeValue(data, for: characteristic, type: type)
    }

    switch type {
    case .withResponse:
      return self.delegate
        .didWriteValueForCharacteristic
        .filter({ $0.characteristic == characteristic })
        .tryMap({ result -> CBCharacteristic in
          if let error = result.error {
            throw error
          }
          return result.characteristic
        })
        .mapError({
          BLEError.writeFailed(
            BLEError.CoreBluetoothError.from(
              error:
                $0 as NSError
            )
          )
        })
        .first()
        .ignoreOutput()
        .eraseToAnyPublisher()
    default:
      return Empty(completeImmediately: true)
        .setFailureType(to: BLEError.self)
        .eraseToAnyPublisher()
    }
  }

  // MARK - private

  private func buildDeferredValuePublisher(
    for characteristic: CBCharacteristic
  ) -> AnyPublisher<BLEData, BLEError> {
    Deferred<AnyPublisher<BLEData, BLEError>> {
      self.delegate
        .didUpdateValueForCharacteristic
        .filter { $0.characteristic.uuid == characteristic.uuid }
        .tryMap { [weak self] filteredPeripheral in
          guard let self = self else { throw BLEError.deallocated }
          guard let data = filteredPeripheral.characteristic.value else {
            throw BLEError.data(.invalid)
          }
          return BLEData(value: data, peripheral: self)
        }
        .mapError { $0 as? BLEError ?? BLEError.unknown }
        .eraseToAnyPublisher()
    }.eraseToAnyPublisher()
  }

}
