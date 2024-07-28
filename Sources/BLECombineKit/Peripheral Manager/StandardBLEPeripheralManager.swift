//
//  StandardBLEPeripheralManager.swift
//  BLECombineKit
//
//  Originally created by Przemyslaw Stasiak on 12/07/2021.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth

final class StandardBLEPeripheralManager: BLEPeripheralManager {

  /// Implementation of the CBPeripheralManager.
  public let manager: CBPeripheralManager

  let delegate: BLEPeripheralManagerDelegate

  /// Lock for checking advertising state
  private let advertisingLock = NSLock()
  /// Is there ongoing advertising
  var isAdvertisingOngoing = false
  var restoredAdvertisementData: RestoredAdvertisementData?

  // MARK: Initialization

  /// Creates new `PeripheralManager`
  /// - parameter peripheralManager: `CBPeripheralManager` instance which is used to perform all of the necessary operations
  /// - parameter delegateWrapper: Wrapper on CoreBluetooth's peripheral manager callbacks.
  init(peripheralManager: CBPeripheralManager, delegate: BLEPeripheralManagerDelegate) {
    self.manager = peripheralManager
    self.delegate = delegate
    peripheralManager.delegate = delegate
  }

  /// Creates new `PeripheralManager` instance. By default all operations and events are executed and received on main thread.
  /// - warning: If you pass background queue to the method make sure to observe results on main thread for UI related code.
  /// - parameter queue: Queue on which bluetooth callbacks are received. By default main thread is used.
  /// - parameter options: An optional dictionary containing initialization options for a peripheral manager.
  /// For more info about it please refer to [Peripheral Manager initialization options](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager/peripheral_manager_initialization_options)
  /// - parameter cbPeripheralManager: Optional instance of `CBPeripheralManager` to be used as a `manager`. If you
  /// skip this parameter, there will be created an instance of `CBPeripheralManager` using given queue and options.
  convenience init(
    queue: DispatchQueue = .main,
    options: [String: AnyObject]? = nil,
    cbPeripheralManager: CBPeripheralManager? = nil
  ) {
    let delegate = BLEPeripheralManagerDelegate()
    #if os(iOS) || os(macOS)
      let peripheralManager =
        cbPeripheralManager
        ?? CBPeripheralManager(delegate: delegate, queue: queue, options: options)
    #else
      let peripheralManager = CBPeripheralManager()
      peripheralManager.delegate = delegateWrapper
    #endif
    self.init(peripheralManager: peripheralManager, delegate: delegate)
  }

  // MARK: State

  var state: CBManagerState {
    return manager.state
  }

  func observeState() -> AnyPublisher<CBManagerState, Never> {
    return self.delegate.didUpdateState.eraseToAnyPublisher()
  }

  func observeStateWithInitialValue() -> AnyPublisher<CBManagerState, Never> {
    return Deferred<AnyPublisher<CBManagerState, Never>> { [weak self] in
      guard let self = self else {
        return Empty().eraseToAnyPublisher()
      }

      return self.observeState()
        .prepend(self.state)
        .eraseToAnyPublisher()
    }
    .eraseToAnyPublisher()
  }

  // MARK: Advertising

  func startAdvertising(_ advertisementData: [String: Any]?) -> AnyPublisher<
    StartAdvertisingResult, BLEError
  > {
    let publisher: AnyPublisher<StartAdvertisingResult, BLEError> = AnyPublisher.create {
      [weak self] observer in
      guard let strongSelf = self else {
        observer.send(completion: .failure(BLEError.deallocated))
        return AnyCancellable {}
      }
      strongSelf.advertisingLock.lock()
      defer { strongSelf.advertisingLock.unlock() }
      if strongSelf.isAdvertisingOngoing {
        observer.send(completion: .failure(BLEError.advertisingInProgress))
        return AnyCancellable {}
      }

      strongSelf.isAdvertisingOngoing = true

      var cancelable: Cancellable?
      if strongSelf.manager.isAdvertising {
        observer.send(.attachedToExternalAdvertising(strongSelf.restoredAdvertisementData))
        strongSelf.restoredAdvertisementData = nil
      }
      else {
        cancelable = strongSelf.delegate.didStartAdvertising
          .prefix(1)
          .tryMap { error throws -> StartAdvertisingResult in
            if let error = error {
              throw BLEError.advertisingStartFailed(error)
            }
            return StartAdvertisingResult.started
          }
          .mapError { $0 as! BLEError }
          .sink(
            receiveCompletion: {
              if case .failure = $0 { observer.send(completion: $0) }
            },
            receiveValue: {
              observer.send($0)
            }
          )
        strongSelf.manager.startAdvertising(advertisementData)
      }
      return AnyCancellable { [weak self] in
        guard let strongSelf = self else { return }
        cancelable?.cancel()
        strongSelf.manager.stopAdvertising()
        do {
          strongSelf.advertisingLock.lock()
          defer { strongSelf.advertisingLock.unlock() }
          strongSelf.isAdvertisingOngoing = false
        }
      }
    }

    return publisher.ensure(.poweredOn, manager: self)
  }

  // MARK: Services

  func add(_ service: CBMutableService) -> AnyPublisher<CBService, BLEError> {
    let observable = delegate
      .didAddService
      .first { $0.0.uuid == service.uuid }
      .tryMap { (cbService, error) throws -> CBService in
        if let error = error {
          throw error
        }
        return cbService
      }
      .mapError { BLEError.addingServiceFailed(service, $0) }
      .eraseToAnyPublisher()
    return ensureValidStateAndCallIfSucceeded(for: observable) {
      [weak self] in
      self?.manager.add(service)
    }
  }

  /// Wrapper for `CBPeripheralManager.remove(_:)` method
  func remove(_ service: CBMutableService) {
    manager.remove(service)
  }

  /// Wrapper for `CBPeripheralManager.removeAllServices()` method
  func removeAllServices() {
    manager.removeAllServices()
  }

  // MARK: Read & Write

  func observeDidReceiveRead() -> AnyPublisher<CBATTRequest, Never> {
    delegate.didReceiveRead.ensure(.poweredOn, manager: self)
  }

  func observeDidReceiveWrite() -> AnyPublisher<[CBATTRequest], Never> {
    delegate.didReceiveWrite.ensure(.poweredOn, manager: self)
  }

  func respond(to request: CBATTRequest, withResult result: CBATTError.Code) {
    manager.respond(to: request, withResult: result)
  }

  // MARK: Updating value

  func updateValue(
    _ value: Data,
    for characteristic: CBMutableCharacteristic,
    onSubscribedCentrals centrals: [CBCentral]?
  ) -> Bool {
    return manager.updateValue(value, for: characteristic, onSubscribedCentrals: centrals)
  }

  func observeIsReadyToUpdateSubscribers() -> AnyPublisher<Void, Never> {
    delegate.isReady.ensure(.poweredOn, manager: self)
  }

  // MARK: Subscribing

  func observeOnSubscribe() -> AnyPublisher<(CBCentral, CBCharacteristic), Never> {
    delegate.didSubscribeTo.ensure(.poweredOn, manager: self)
  }

  func observeOnUnsubscribe() -> AnyPublisher<(CBCentral, CBCharacteristic), Never> {
    delegate.didUnsubscribeFrom.ensure(.poweredOn, manager: self)
  }

  // MARK: L2CAP

  #if os(iOS) || os(tvOS) || os(watchOS)

    func publishL2CAPChannel(
      withEncryption encryptionRequired: Bool
    ) -> AnyPublisher<CBL2CAPPSM, BLEError> {
      let observable: AnyPublisher<CBL2CAPPSM, BLEError> = .create { [weak self] observer in
        guard let strongSelf = self else {
          observer.send(completion: .failure(.deallocated))
          return AnyCancellable {}
        }

        var result: CBL2CAPPSM?
        let cancellable = strongSelf.delegateWrapper.didPublishL2CAPChannel
          .prefix(1)
          .tryMap { (cbl2cappSm, error) throws -> (CBL2CAPPSM) in
            if let error = error {
              throw BLEError.publishingL2CAPChannelFailed(cbl2cappSm, error)
            }
            result = cbl2cappSm
            return cbl2cappSm
          }
          .mapError { $0 as! BLEError }
          .sink(
            receiveCompletion: { observer.send(completion: $0) },
            receiveValue: { observer.send($0) }
          )
        strongSelf.manager.publishL2CAPChannel(withEncryption: encryptionRequired)
        return AnyCancellable { [weak self] in
          guard let strongSelf = self else { return }
          cancellable.cancel()
          if let result = result {
            strongSelf.manager.unpublishL2CAPChannel(result)
          }
        }
      }
      return observable.ensure(.poweredOn, manager: self)
    }

    func observeDidOpenL2CAPChannel() -> AnyPublisher<(CBL2CAPChannel?, Error?), Never> {
      delegateWrapper.didOpenChannel.ensure(.poweredOn, manager: self)
    }
  #endif

  // MARK: Internal functions

  func ensureValidStateAndCallIfSucceeded<T, F>(
    for publisher: AnyPublisher<T, F>,
    postSubscriptionCall call: @escaping () -> Void
  ) -> AnyPublisher<T, F> {
    Deferred<AnyPublisher<T, F>> {
      defer { call() }
      return
        publisher
        .ensure(.poweredOn, manager: self)
    }.eraseToAnyPublisher()
  }
}

extension Publisher {

  // TODO: update the code to return a Failure instead of completing when the state changes from poweredOn to a different one (or when the state is poweredOff when `ensure` is called.) This will allow the downstream to understand why it is being completed instead of just completing without a reason.

  /// This publisher will keep publishing events from the upstream until the given state changes to another one.
  fileprivate func ensure(
    _ state: CBManagerState,
    manager: BLEPeripheralManager
  ) -> AnyPublisher<Self.Output, Self.Failure> {
    let outputStream = manager.observeStateWithInitialValue()
      .filter { $0 != state }
    return self.prefix(untilOutputFrom: outputStream)
      .eraseToAnyPublisher()
  }
}
