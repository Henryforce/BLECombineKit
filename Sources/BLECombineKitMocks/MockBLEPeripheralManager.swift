//
//  MockBLEPeripheralManager.swift
//  BLECombineKitMocks
// Polish from existing test mocks
//

import BLECombineKit
import Combine
import CoreBluetooth
import Foundation

/// A mock implementation of `BLEPeripheralManager` for testing purposes.
open class MockBLEPeripheralManager: BLEPeripheralManager, @unchecked Sendable {

  public init() {}

  /// The state of the peripheral manager.
  public var stateValue: CBManagerState = .unknown
  public var state: CBManagerState {
    stateValue
  }

  /// Return value for `observeState()`.
  public var observeStateReturnValue: AnyPublisher<CBManagerState, Never> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `observeState()` was called.
  public var observeStateWasCalledCount = 0

  /// Mocks observing the state of the peripheral manager.
  public func observeState() -> AnyPublisher<CBManagerState, Never> {
    observeStateWasCalledCount += 1
    return observeStateReturnValue
  }

  /// Return value for `observeStateWithInitialValue()`.
  public var observeStateWithInitialValueReturnValue: AnyPublisher<CBManagerState, Never> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `observeStateWithInitialValue()` was called.
  public var observeStateWithInitialValueWasCalledCount = 0

  /// Mocks observing the state of the peripheral manager with an initial value.
  public func observeStateWithInitialValue() -> AnyPublisher<CBManagerState, Never> {
    observeStateWithInitialValueWasCalledCount += 1
    return observeStateWithInitialValueReturnValue
  }

  /// Return value for `startAdvertising(_:)`.
  public var startAdvertisingReturnValue: AnyPublisher<StartAdvertisingResult, BLEError> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `startAdvertising(_:)` was called.
  public var startAdvertisingWasCalledCount = 0
  /// The advertisement data passed to the last call of `startAdvertising(_:)`.
  public var startAdvertisingData: [String: Any]?

  /// Mocks starting to advertise data.
  public func startAdvertising(_ advertisementData: [String: Any]?) -> AnyPublisher<
    StartAdvertisingResult, BLEError
  > {
    startAdvertisingWasCalledCount += 1
    startAdvertisingData = advertisementData
    return startAdvertisingReturnValue
  }

  /// Return value for `add(_:)`.
  public var addReturnValue: AnyPublisher<CBService, BLEError> = Empty().eraseToAnyPublisher()
  /// Count of how many times `add(_:)` was called.
  public var addWasCalledCount = 0
  /// The service passed to the last call of `add(_:)`.
  public var addService: CBMutableService?

  /// Mocks adding a service to the peripheral manager.
  public func add(_ service: CBMutableService) -> AnyPublisher<CBService, BLEError> {
    addWasCalledCount += 1
    addService = service
    return addReturnValue
  }

  /// Count of how many times `remove(_:)` was called.
  public var removeWasCalledCount = 0
  /// The service passed to the last call of `remove(_:)`.
  public var removeService: CBMutableService?

  /// Mocks removing a service from the peripheral manager.
  public func remove(_ service: CBMutableService) {
    removeWasCalledCount += 1
    removeService = service
  }

  /// Count of how many times `removeAllServices()` was called.
  public var removeAllServicesWasCalledCount = 0

  /// Mocks removing all services from the peripheral manager.
  public func removeAllServices() {
    removeAllServicesWasCalledCount += 1
  }

  /// Return value for `observeDidReceiveRead()`.
  public var observeDidReceiveReadReturnValue: AnyPublisher<BLEATTRequest, Never> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `observeDidReceiveRead()` was called.
  public var observeDidReceiveReadWasCalledCount = 0

  /// Mocks observing read requests.
  public func observeDidReceiveRead() -> AnyPublisher<BLEATTRequest, Never> {
    observeDidReceiveReadWasCalledCount += 1
    return observeDidReceiveReadReturnValue
  }

  /// Return value for `observeDidReceiveWrite()`.
  public var observeDidReceiveWriteReturnValue: AnyPublisher<[BLEATTRequest], Never> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `observeDidReceiveWrite()` was called.
  public var observeDidReceiveWriteWasCalledCount = 0

  /// Mocks observing write requests.
  public func observeDidReceiveWrite() -> AnyPublisher<[BLEATTRequest], Never> {
    observeDidReceiveWriteWasCalledCount += 1
    return observeDidReceiveWriteReturnValue
  }

  /// Count of how many times `respond(to:withResult:)` was called.
  public var respondWasCalledCount = 0
  /// The request passed to the last call of `respond(to:withResult:)`.
  public var respondRequest: BLEATTRequest?
  /// The result passed to the last call of `respond(to:withResult:)`.
  public var respondResult: CBATTError.Code?

  /// Mocks responding to an ATT request.
  public func respond(to request: BLEATTRequest, withResult result: CBATTError.Code) {
    respondWasCalledCount += 1
    respondRequest = request
    respondResult = result
  }

  /// Return value for `updateValue(_:for:onSubscribedCentrals:)`.
  public var updateValueReturnValue: Bool = false
  /// Count of how many times `updateValue(_:for:onSubscribedCentrals:)` was called.
  public var updateValueWasCalledCount = 0
  /// The data passed to the last call of `updateValue(_:for:onSubscribedCentrals:)`.
  public var updateValueData: Data?
  /// The characteristic passed to the last call of `updateValue(_:for:onSubscribedCentrals:)`.
  public var updateValueCharacteristic: CBMutableCharacteristic?
  /// The centrals passed to the last call of `updateValue(_:for:onSubscribedCentrals:)`.
  public var updateValueCentrals: [BLECentral]?

  /// Mocks updating a characteristic's value.
  public func updateValue(
    _ value: Data, for characteristic: CBMutableCharacteristic,
    onSubscribedCentrals centrals: [BLECentral]?
  ) -> Bool {
    updateValueWasCalledCount += 1
    updateValueData = value
    updateValueCharacteristic = characteristic
    updateValueCentrals = centrals
    return updateValueReturnValue
  }

  /// Return value for `observeIsReadyToUpdateSubscribers()`.
  public var observeIsReadyToUpdateSubscribersReturnValue: AnyPublisher<Void, Never> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `observeIsReadyToUpdateSubscribers()` was called.
  public var observeIsReadyToUpdateSubscribersWasCalledCount = 0

  /// Mocks observing when the manager is ready to update subscribers.
  public func observeIsReadyToUpdateSubscribers() -> AnyPublisher<Void, Never> {
    observeIsReadyToUpdateSubscribersWasCalledCount += 1
    return observeIsReadyToUpdateSubscribersReturnValue
  }

  /// Return value for `observeOnSubscribe()`.
  public var observeOnSubscribeReturnValue: AnyPublisher<(BLECentral, CBCharacteristic), Never> =
    Empty().eraseToAnyPublisher()
  /// Count of how many times `observeOnSubscribe()` was called.
  public var observeOnSubscribeWasCalledCount = 0

  /// Mocks observing when a central subscribes to a characteristic.
  public func observeOnSubscribe() -> AnyPublisher<(BLECentral, CBCharacteristic), Never> {
    observeOnSubscribeWasCalledCount += 1
    return observeOnSubscribeReturnValue
  }

  /// Return value for `observeOnUnsubscribe()`.
  public var observeOnUnsubscribeReturnValue: AnyPublisher<(BLECentral, CBCharacteristic), Never> =
    Empty().eraseToAnyPublisher()
  /// Count of how many times `observeOnUnsubscribe()` was called.
  public var observeOnUnsubscribeWasCalledCount = 0

  /// Mocks observing when a central unsubscribes from a characteristic.
  public func observeOnUnsubscribe() -> AnyPublisher<(BLECentral, CBCharacteristic), Never> {
    observeOnUnsubscribeWasCalledCount += 1
    return observeOnUnsubscribeReturnValue
  }

  #if os(iOS) || os(tvOS) || os(watchOS)
    /// Return value for `publishL2CAPChannel(withEncryption:)`.
    public var publishL2CAPChannelReturnValue: AnyPublisher<CBL2CAPPSM, BLEError> = Empty()
      .eraseToAnyPublisher()
    /// Count of how many times `publishL2CAPChannel(withEncryption:)` was called.
    public var publishL2CAPChannelWasCalledCount = 0
    /// The encryption requirement passed to the last call of `publishL2CAPChannel(withEncryption:)`.
    public var publishL2CAPChannelEncryptionRequired: Bool?

    /// Mocks publishing an L2CAP channel.
    public func publishL2CAPChannel(withEncryption encryptionRequired: Bool) -> AnyPublisher<
      CBL2CAPPSM, BLEError
    > {
      publishL2CAPChannelWasCalledCount += 1
      publishL2CAPChannelEncryptionRequired = encryptionRequired
      return publishL2CAPChannelReturnValue
    }

    /// Return value for `observeDidOpenL2CAPChannel()`.
    public var observeDidOpenL2CAPChannelReturnValue:
      AnyPublisher<(CBL2CAPChannel?, Error?), Never> = Empty().eraseToAnyPublisher()
    /// Count of how many times `observeDidOpenL2CAPChannel()` was called.
    public var observeDidOpenL2CAPChannelWasCalledCount = 0

    /// Mocks observing when an L2CAP channel is opened.
    public func observeDidOpenL2CAPChannel() -> AnyPublisher<(CBL2CAPChannel?, Error?), Never> {
      observeDidOpenL2CAPChannelWasCalledCount += 1
      return observeDidOpenL2CAPChannelReturnValue
    }
  #endif
}
