//
//  BLEPeripheralManager.swift
//  BLECombineKit
//
//  Created by Przemyslaw Stasiak on 12/07/2021.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine
import CombineExt

/// BLEPeripheralManager is a class implementing ReactiveX API which wraps all the Core Bluetooth Peripheral's functions, that allow to
/// advertise, to publish L2CAP channels and more.
/// You can start using this class by adding services and starting advertising.
/// Before calling any public `BLEPeripheralManager`'s functions you should make sure that Bluetooth is turned on and powered on. It can be done
/// by `observeStateWithInitialValue()`, observing it's value and then chaining it with `add(_:)` and `startAdvertising(_:)`:
/// ```
/// let disposable = peripheralManager.observeStateWithInitialValue()
///     .filter { $0 == .poweredOn }
///     .take(1)
///     .flatMap { peripheralManager.add(myService) }
///     .flatMap { peripheralManager.startAdvertising(myAdvertisementData) }
/// ```
/// As a result, your peripheral will start advertising. To stop advertising simply cancel it:
/// ```
/// cancellable.cancel()
/// ```
public class BLEPeripheralManager {

    /// Implementation of CBPeripheralManager
    public let manager: CBPeripheralManager

    let delegateWrapper: BLEPeripheralManagerDelegateWrapper

    /// Lock for checking advertising state
    private let advertisingLock = NSLock()
    /// Is there ongoing advertising
    var isAdvertisingOngoing = false
    var restoredAdvertisementData: RestoredAdvertisementData?

    // MARK: Initialization

    /// Creates new `PeripheralManager`
    /// - parameter peripheralManager: `CBPeripheralManager` instance which is used to perform all of the necessary operations
    /// - parameter delegateWrapper: Wrapper on CoreBluetooth's peripheral manager callbacks.
    init(peripheralManager: CBPeripheralManager, delegateWrapper: BLEPeripheralManagerDelegateWrapper) {
        self.manager = peripheralManager
        self.delegateWrapper = delegateWrapper
        peripheralManager.delegate = delegateWrapper
    }

    /// Creates new `PeripheralManager` instance. By default all operations and events are executed and received on main thread.
    /// - warning: If you pass background queue to the method make sure to observe results on main thread for UI related code.
    /// - parameter queue: Queue on which bluetooth callbacks are received. By default main thread is used.
    /// - parameter options: An optional dictionary containing initialization options for a peripheral manager.
    /// For more info about it please refer to [Peripheral Manager initialization options](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager/peripheral_manager_initialization_options)
    /// - parameter cbPeripheralManager: Optional instance of `CBPeripheralManager` to be used as a `manager`. If you
    /// skip this parameter, there will be created an instance of `CBPeripheralManager` using given queue and options.
    public convenience init(queue: DispatchQueue = .main,
                            options: [String: AnyObject]? = nil,
                            cbPeripheralManager: CBPeripheralManager? = nil) {
        let delegateWrapper = BLEPeripheralManagerDelegateWrapper()
        #if os(iOS) || os(macOS)
        let peripheralManager = cbPeripheralManager ??
            CBPeripheralManager(delegate: delegateWrapper, queue: queue, options: options)
        #else
        let peripheralManager = CBPeripheralManager()
        peripheralManager.delegate = delegateWrapper
        #endif
        self.init(peripheralManager: peripheralManager, delegateWrapper: delegateWrapper)
    }

    /// Returns the app’s authorization status for sharing data while in the background state.
    /// Wrapper of `CBPeripheralManager.authorizationStatus()` method.
    static var authorizationStatus: CBPeripheralManagerAuthorizationStatus {
        return CBPeripheralManager.authorizationStatus()
    }

    // MARK: State

    public var state: ManagerState {
        return ManagerState(rawValue: manager.state.rawValue) ?? .unknown
    }

    public func observeState() -> AnyPublisher<ManagerState, Never> {
        return self.delegateWrapper.didUpdateState.eraseToAnyPublisher()
    }

    public func observeStateWithInitialValue() -> AnyPublisher<ManagerState, Never> {
        return Deferred<AnyPublisher<ManagerState, Never>> { [weak self] in
            guard let self = self else {
                return Empty().eraseToAnyPublisher()
            }

            return self.delegateWrapper.didUpdateState
                .eraseToAnyPublisher()
                .prepend(self.state)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    // MARK: Advertising

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
    /// - returns: Infinite observable which emit `StartAdvertisingResult` when advertisement started.
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
    public func startAdvertising(_ advertisementData: [String: Any]?) -> AnyPublisher<StartAdvertisingResult, BLEError> {
        let publisher: AnyPublisher<StartAdvertisingResult, BLEError> = AnyPublisher.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.send(completion: .failure(BLEError.deallocated))
                return AnyCancellable {}
            }
            strongSelf.advertisingLock.lock(); defer { strongSelf.advertisingLock.unlock() }
            if strongSelf.isAdvertisingOngoing {
                observer.send(completion: .failure(BLEError.advertisingInProgress))
                return AnyCancellable {}
            }

            strongSelf.isAdvertisingOngoing = true

            var cancelable: Cancellable?
            if strongSelf.manager.isAdvertising {
                observer.send(.attachedToExternalAdvertising(strongSelf.restoredAdvertisementData))
                strongSelf.restoredAdvertisementData = nil
            } else {
                cancelable = strongSelf.delegateWrapper.didStartAdvertising
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
                do { strongSelf.advertisingLock.lock(); defer { strongSelf.advertisingLock.unlock() }
                    strongSelf.isAdvertisingOngoing = false
                }
            }
        }

        return publisher.ensure(.poweredOn, manager: self)
    }

    // MARK: Services

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
    public func add(_ service: CBMutableService) -> AnyPublisher<CBService, BLEError> {
        let observable = delegateWrapper
            .didAddService
            .filter { $0.0.uuid == service.uuid }
            .prefix(1)
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
    public func remove(_ service: CBMutableService) {
        manager.remove(service)
    }

    /// Wrapper for `CBPeripheralManager.removeAllServices()` method
    public func removeAllServices() {
        manager.removeAllServices()
    }

    // MARK: Read & Write

    /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManager(_:didReceiveRead:)` results
    /// - returns: Observable that emits `next` event whenever didReceiveRead occurs.
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
    public func observeDidReceiveRead() -> AnyPublisher<CBATTRequest, Never> {
        delegateWrapper.didReceiveRead.ensure(.poweredOn, manager: self)
    }

    /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManager(_:didReceiveWrite:)` results
    /// - returns: Observable that emits `next` event whenever didReceiveWrite occurs.
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
    public func observeDidReceiveWrite() -> AnyPublisher<[CBATTRequest], Never> {
        delegateWrapper.didReceiveWrite.ensure(.poweredOn, manager: self)
    }

    /// Wrapper for `CBPeripheralManager.respond(to:withResult:)` method
    public func respond(to request: CBATTRequest, withResult result: CBATTError.Code) {
        manager.respond(to: request, withResult: result)
    }

    // MARK: Updating value

    /// Wrapper for `CBPeripheralManager.updateValue(_:for:onSubscribedCentrals:)` method
    public func updateValue(
        _ value: Data,
        for characteristic: CBMutableCharacteristic,
        onSubscribedCentrals centrals: [CBCentral]?) -> Bool {
        return manager.updateValue(value, for: characteristic, onSubscribedCentrals: centrals)
    }

    /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManagerIsReady(toUpdateSubscribers:)` results
    /// - returns: Observable that emits `next` event whenever isReadyToUpdateSubscribers occurs.
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
    public func observeIsReadyToUpdateSubscribers() -> AnyPublisher<Void, Never> {
        delegateWrapper.isReady.ensure(.poweredOn, manager: self)
    }

    // MARK: Subscribing

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
    public func observeOnSubscribe() -> AnyPublisher<(CBCentral, CBCharacteristic), Never> {
        delegateWrapper.didSubscribeTo.ensure(.poweredOn, manager: self)
    }

    /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManager(_:central:didUnsubscribeFrom:)` results
    /// - returns: Observable that emits `next` event whenever didUnsubscribeFrom occurs.
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
    public func observeOnUnsubscribe() -> AnyPublisher<(CBCentral, CBCharacteristic), Never> {
        delegateWrapper.didUnsubscribeFrom.ensure(.poweredOn, manager: self)
    }

    // MARK: L2CAP

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
    /// - returns: Infinite observable which emit `CBL2CAPPSM` when channel published.
    ///
    /// Observable can ends with following errors:
    /// * `BLEError.publishingL2CAPChannelFailed`
    /// * `BLEError.deallocated`
    /// * `BLEError.bluetoothUnsupported`
    /// * `BLEError.bluetoothUnauthorized`
    /// * `BLEError.bluetoothPoweredOff`
    /// * `BLEError.bluetoothInUnknownState`
    /// * `BLEError.bluetoothResetting`
    @available(iOS 11, tvOS 11, watchOS 4, *)
    public func publishL2CAPChannel(withEncryption encryptionRequired: Bool) -> AnyPublisher<CBL2CAPPSM, BLEError> {
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
                .sink(receiveCompletion: { observer.send(completion: $0) }, receiveValue: { observer.send($0) })
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

    /// Continuous observer for `CBPeripheralManagerDelegate.peripheralManager(_:didOpen:error:)` results
    /// - returns: Observable that emits `next` event whenever didOpen occurs.
    ///
    /// It's **infinite** stream, so `.complete` is never called.
    ///
    @available(iOS 11, tvOS 11, watchOS 4, *)
    public func observeDidOpenL2CAPChannel() -> AnyPublisher<(CBL2CAPChannel?, Error?), Never> {
        delegateWrapper.didOpenChannel.ensure(.poweredOn, manager: self)
    }
    #endif

    // MARK: Internal functions

    func ensureValidStateAndCallIfSucceeded<T, F>(for publisher: AnyPublisher<T, F>,
                                               postSubscriptionCall call: @escaping () -> Void
        ) -> AnyPublisher<T, F> {
        let operation = Deferred<Empty<T, F>> {
            call()
            return Empty()
        }
        return publisher
            .merge(with: operation)
            .ensure(.poweredOn, manager: self)
    }
}

private extension Publisher {
    
    func ensure(_ state: ManagerState, manager: BLEPeripheralManager) -> AnyPublisher<Self.Output, Self.Failure> {
        self.prefix(untilOutputFrom: manager.observeStateWithInitialValue().filter { $0 != state }).eraseToAnyPublisher()
    }
}
