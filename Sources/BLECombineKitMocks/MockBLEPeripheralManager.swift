//
//  MockBLEPeripheralManager.swift
//  BLECombineKitMocks
// Polish from existing test mocks
//

import Combine
import CoreBluetooth
import Foundation
import BLECombineKit

open class MockBLEPeripheralManager: BLEPeripheralManager, @unchecked Sendable {

    public init() { }

    public var stateValue: CBManagerState = .unknown
    public var state: CBManagerState {
        stateValue
    }

    public var observeStateReturnValue: AnyPublisher<CBManagerState, Never> = Empty().eraseToAnyPublisher()
    public var observeStateWasCalledCount = 0
    public func observeState() -> AnyPublisher<CBManagerState, Never> {
        observeStateWasCalledCount += 1
        return observeStateReturnValue
    }

    public var observeStateWithInitialValueReturnValue: AnyPublisher<CBManagerState, Never> = Empty().eraseToAnyPublisher()
    public var observeStateWithInitialValueWasCalledCount = 0
    public func observeStateWithInitialValue() -> AnyPublisher<CBManagerState, Never> {
        observeStateWithInitialValueWasCalledCount += 1
        return observeStateWithInitialValueReturnValue
    }

    public var startAdvertisingReturnValue: AnyPublisher<StartAdvertisingResult, BLEError> = Empty().eraseToAnyPublisher()
    public var startAdvertisingWasCalledCount = 0
    public var startAdvertisingData: [String: Any]?
    public func startAdvertising(_ advertisementData: [String: Any]?) -> AnyPublisher<StartAdvertisingResult, BLEError> {
        startAdvertisingWasCalledCount += 1
        startAdvertisingData = advertisementData
        return startAdvertisingReturnValue
    }

    public var addReturnValue: AnyPublisher<CBService, BLEError> = Empty().eraseToAnyPublisher()
    public var addWasCalledCount = 0
    public var addService: CBMutableService?
    public func add(_ service: CBMutableService) -> AnyPublisher<CBService, BLEError> {
        addWasCalledCount += 1
        addService = service
        return addReturnValue
    }

    public var removeWasCalledCount = 0
    public var removeService: CBMutableService?
    public func remove(_ service: CBMutableService) {
        removeWasCalledCount += 1
        removeService = service
    }

    public var removeAllServicesWasCalledCount = 0
    public func removeAllServices() {
        removeAllServicesWasCalledCount += 1
    }

    public var observeDidReceiveReadReturnValue: AnyPublisher<BLEATTRequest, Never> = Empty().eraseToAnyPublisher()
    public var observeDidReceiveReadWasCalledCount = 0
    public func observeDidReceiveRead() -> AnyPublisher<BLEATTRequest, Never> {
        observeDidReceiveReadWasCalledCount += 1
        return observeDidReceiveReadReturnValue
    }

    public var observeDidReceiveWriteReturnValue: AnyPublisher<[BLEATTRequest], Never> = Empty().eraseToAnyPublisher()
    public var observeDidReceiveWriteWasCalledCount = 0
    public func observeDidReceiveWrite() -> AnyPublisher<[BLEATTRequest], Never> {
        observeDidReceiveWriteWasCalledCount += 1
        return observeDidReceiveWriteReturnValue
    }

    public var respondWasCalledCount = 0
    public var respondRequest: BLEATTRequest?
    public var respondResult: CBATTError.Code?
    public func respond(to request: BLEATTRequest, withResult result: CBATTError.Code) {
        respondWasCalledCount += 1
        respondRequest = request
        respondResult = result
    }

    public var updateValueReturnValue: Bool = false
    public var updateValueWasCalledCount = 0
    public var updateValueData: Data?
    public var updateValueCharacteristic: CBMutableCharacteristic?
    public var updateValueCentrals: [BLECentral]?
    public func updateValue(_ value: Data, for characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [BLECentral]?) -> Bool {
        updateValueWasCalledCount += 1
        updateValueData = value
        updateValueCharacteristic = characteristic
        updateValueCentrals = centrals
        return updateValueReturnValue
    }

    public var observeIsReadyToUpdateSubscribersReturnValue: AnyPublisher<Void, Never> = Empty().eraseToAnyPublisher()
    public var observeIsReadyToUpdateSubscribersWasCalledCount = 0
    public func observeIsReadyToUpdateSubscribers() -> AnyPublisher<Void, Never> {
        observeIsReadyToUpdateSubscribersWasCalledCount += 1
        return observeIsReadyToUpdateSubscribersReturnValue
    }

    public var observeOnSubscribeReturnValue: AnyPublisher<(BLECentral, CBCharacteristic), Never> = Empty().eraseToAnyPublisher()
    public var observeOnSubscribeWasCalledCount = 0
    public func observeOnSubscribe() -> AnyPublisher<(BLECentral, CBCharacteristic), Never> {
        observeOnSubscribeWasCalledCount += 1
        return observeOnSubscribeReturnValue
    }

    public var observeOnUnsubscribeReturnValue: AnyPublisher<(BLECentral, CBCharacteristic), Never> = Empty().eraseToAnyPublisher()
    public var observeOnUnsubscribeWasCalledCount = 0
    public func observeOnUnsubscribe() -> AnyPublisher<(BLECentral, CBCharacteristic), Never> {
        observeOnUnsubscribeWasCalledCount += 1
        return observeOnUnsubscribeReturnValue
    }

    #if os(iOS) || os(tvOS) || os(watchOS)
    public var publishL2CAPChannelReturnValue: AnyPublisher<CBL2CAPPSM, BLEError> = Empty().eraseToAnyPublisher()
    public var publishL2CAPChannelWasCalledCount = 0
    public var publishL2CAPChannelEncryptionRequired: Bool?
    public func publishL2CAPChannel(withEncryption encryptionRequired: Bool) -> AnyPublisher<CBL2CAPPSM, BLEError> {
        publishL2CAPChannelWasCalledCount += 1
        publishL2CAPChannelEncryptionRequired = encryptionRequired
        return publishL2CAPChannelReturnValue
    }

    public var observeDidOpenL2CAPChannelReturnValue: AnyPublisher<(CBL2CAPChannel?, Error?), Never> = Empty().eraseToAnyPublisher()
    public var observeDidOpenL2CAPChannelWasCalledCount = 0
    public func observeDidOpenL2CAPChannel() -> AnyPublisher<(CBL2CAPChannel?, Error?), Never> {
        observeDidOpenL2CAPChannelWasCalledCount += 1
        return observeDidOpenL2CAPChannelReturnValue
    }
    #endif
}
