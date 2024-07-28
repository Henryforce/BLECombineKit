//
//  BLEPeripheralManager.swift
//  BLECombineKit
//
//  Created by Przemyslaw Stasiak on 12/07/2021.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth

/// BLEPeripheralManager is an implementation based on the ReactiveX API which wraps all the Core Bluetooth Peripheral's functions, that allows to
/// advertise, to publish L2CAP channels and more.
/// You can start using this class by adding services and starting advertising.
/// Before calling any public `BLEPeripheralManager`'s functions you should make sure that Bluetooth is turned on and powered on. It can be done
/// by `observeStateWithInitialValue()`, observing it's value and then chaining it with `add(_:)` and `startAdvertising(_:)`:
/// ```
/// let disposable = peripheralManager.observeStateWithInitialValue()
///     .first { $0 == .poweredOn }
///     .flatMap { peripheralManager.add(myService) }
///     .flatMap { peripheralManager.startAdvertising(myAdvertisementData) }
/// ```
/// As a result, your peripheral will start advertising. To stop advertising simply cancel it:
/// ```
/// cancellable.cancel()
/// ```
public protocol BLEPeripheralManager {
  var state: CBManagerState { get }

  func observeState() -> AnyPublisher<CBManagerState, Never>

  func observeStateWithInitialValue() -> AnyPublisher<CBManagerState, Never>

  /// Starts peripheral advertising on subscription. It create inifinite publisher
  /// which emits only one next value, of enum type `StartAdvertisingResult`, just
  /// after advertising start succeeds.
  /// For more info of what specific `StartAdvertisingResult` enum cases means please
  /// refer to ``StartAdvertisingResult` documentation.
  ///
  /// There can be only one ongoing advertising (CoreBluetooth limit).
  /// It will return `advertisingInProgress` error if this method is called when
  /// it is already advertising.
  ///
  /// Advertising is automatically stopped just after disposing of the subscription.
  ///
  /// It can return `BLEError.advertisingStartFailed` error, when start advertisement failed
  ///
  /// - parameter advertisementData: Services of peripherals to search for. Nil value will accept all peripherals.
  /// - Returns: Infinite observable which emit `StartAdvertisingResult` when advertisement started.
  ///
  /// Publisher can ends with following errors:
  /// * `BLEError.advertisingInProgress`
  /// * `BLEError.advertisingStartFailed`
  /// * `BLEError.deallocated`
  /// * `BLEError.bluetoothUnsupported`
  /// * `BLEError.bluetoothUnauthorized`
  /// * `BLEError.bluetoothPoweredOff`
  /// * `BLEError.bluetoothInUnknownState`
  /// * `BLEError.bluetoothResetting`
  func startAdvertising(
    _ advertisementData: [String: Any]?
  ) -> AnyPublisher<StartAdvertisingResult, BLEError>

  /// Function that triggers `CBPeripheralManager.add(_:)` and waits for
  /// delegate `CBPeripheralManagerDelegate.peripheralManager(_:didAdd:error:)` result.
  /// If it receives a non nil in the result, it will emit `BLEError.addingServiceFailed` error.
  /// Add method is called after subscription to `AnyPublisher` is made.
  /// - Parameter service: `Characteristic` to read value from
  /// - Returns: `AnyPublisher` which emits single `next` with given characteristic when value is ready to read.
  ///
  /// Observable can ends with following errors:
  /// * `BLEError.addingServiceFailed`
  /// * `BLEError.deallocated`
  /// * `BLEError.bluetoothUnsupported`
  /// * `BLEError.bluetoothUnauthorized`
  /// * `BLEError.bluetoothPoweredOff`
  /// * `BLEError.bluetoothInUnknownState`
  /// * `BLEError.bluetoothResetting`
  func add(_ service: CBMutableService) -> AnyPublisher<CBService, BLEError>

  /// Wrapper for `CBPeripheralManager.remove(_:)` method
  func remove(_ service: CBMutableService)

  /// Wrapper for `CBPeripheralManager.removeAllServices()` method
  func removeAllServices()

  /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManager(_:didReceiveRead:)` results
  /// - Returns: Observable that emits `next` event whenever didReceiveRead occurs.
  ///
  /// It's an **infinite** stream, so `.complete` is never called.
  ///
  /// Observable can end with following errors:
  /// * `BLEError.deallocated`
  /// * `BLEError.bluetoothUnsupported`
  /// * `BLEError.bluetoothUnauthorized`
  /// * `BLEError.bluetoothPoweredOff`
  /// * `BLEError.bluetoothInUnknownState`
  /// * `BLEError.bluetoothResetting`
  func observeDidReceiveRead() -> AnyPublisher<CBATTRequest, Never>

  /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManager(_:didReceiveWrite:)` results
  /// - Returns: Observable that emits `next` event whenever didReceiveWrite occurs.
  ///
  /// It's **infinite** stream, so `.complete` is never called.
  ///
  /// Observable can ends with following errors:
  /// * `BLEError.deallocated`
  /// * `BLEError.bluetoothUnsupported`
  /// * `BLEError.bluetoothUnauthorized`
  /// * `BLEError.bluetoothPoweredOff`
  /// * `BLEError.bluetoothInUnknownState`
  /// * `BLEError.bluetoothResetting`
  func observeDidReceiveWrite() -> AnyPublisher<[CBATTRequest], Never>

  /// Wrapper for `CBPeripheralManager.respond(to:withResult:)` method
  func respond(to request: CBATTRequest, withResult result: CBATTError.Code)

  /// Wrapper for `CBPeripheralManager.updateValue(_:for:onSubscribedCentrals:)` method
  func updateValue(
    _ value: Data,
    for characteristic: CBMutableCharacteristic,
    onSubscribedCentrals centrals: [CBCentral]?
  ) -> Bool

  /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManagerIsReady(toUpdateSubscribers:)` results
  /// - Returns: Observable that emits `next` event whenever isReadyToUpdateSubscribers occurs.
  ///
  /// It's **infinite** stream, so `.complete` is never called.
  ///
  /// Observable can ends with following errors:
  /// * `BLEError.deallocated`
  /// * `BLEError.bluetoothUnsupported`
  /// * `BLEError.bluetoothUnauthorized`
  /// * `BLEError.bluetoothPoweredOff`
  /// * `BLEError.bluetoothInUnknownState`
  /// * `BLEError.bluetoothResetting`
  func observeIsReadyToUpdateSubscribers() -> AnyPublisher<Void, Never>

  /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManager(_:central:didSubscribeTo:)` results
  /// - returns: Observable that emits `next` event whenever didSubscribeTo occurs.
  ///
  /// It's **infinite** stream, so `.complete` is never called.
  ///
  /// Observable can ends with following errors:
  /// * `BLEError.deallocated`
  /// * `BLEError.bluetoothUnsupported`
  /// * `BLEError.bluetoothUnauthorized`
  /// * `BLEError.bluetoothPoweredOff`
  /// * `BLEError.bluetoothInUnknownState`
  /// * `BLEError.bluetoothResetting`
  func observeOnSubscribe() -> AnyPublisher<(CBCentral, CBCharacteristic), Never>

  /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManager(_:central:didUnsubscribeFrom:)` results
  /// - Returns: Observable that emits `next` event whenever didUnsubscribeFrom occurs.
  ///
  /// It's **infinite** stream, so `.complete` is never called.
  ///
  /// Observable can ends with following errors:
  /// * `BLEError.deallocated`
  /// * `BLEError.bluetoothUnsupported`
  /// * `BLEError.bluetoothUnauthorized`
  /// * `BLEError.bluetoothPoweredOff`
  /// * `BLEError.bluetoothInUnknownState`
  /// * `BLEError.bluetoothResetting`
  func observeOnUnsubscribe() -> AnyPublisher<(CBCentral, CBCharacteristic), Never>

  #if os(iOS) || os(tvOS) || os(watchOS)
    /// Starts publishing L2CAP channel on a subscription. It creates an infinite observable
    /// which emits only one next value, of `CBL2CAPPSM` type, just
    /// after L2CAP channel has been published.
    ///
    /// Channel is automatically unpublished just after disposing of the subscription.
    ///
    /// It can return `publishingL2CAPChannelFailed` error when publishing channel failed
    ///
    /// - parameter encryptionRequired: Publishing channel with or without encryption.
    /// - Returns: Infinite observable which emit `CBL2CAPPSM` when channel published.
    ///
    /// Observable can ends with following errors:
    /// * `BLEError.publishingL2CAPChannelFailed`
    /// * `BLEError.deallocated`
    /// * `BLEError.bluetoothUnsupported`
    /// * `BLEError.bluetoothUnauthorized`
    /// * `BLEError.bluetoothPoweredOff`
    /// * `BLEError.bluetoothInUnknownState`
    /// * `BLEError.bluetoothResetting`
    func publishL2CAPChannel(
      withEncryption encryptionRequired: Bool
    ) -> AnyPublisher<CBL2CAPPSM, BLEError>

    /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManager(_:didOpen:error:)` results
    /// - Returns: Observable that emits `next` event whenever didOpen occurs.
    ///
    /// It's **infinite** stream, so `.complete` is never called.
    ///
    func observeDidOpenL2CAPChannel() -> AnyPublisher<(CBL2CAPChannel?, Error?), Never>

  #endif
}
