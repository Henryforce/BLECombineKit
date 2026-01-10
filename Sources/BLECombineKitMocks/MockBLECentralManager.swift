//
//  MockBLECentralManager.swift
//  BLECombineKitMocks
//
//  Created by Henry Javier Serrano Echeverria on 10/1/26.
//

import Combine
import CoreBluetooth
import Foundation
import BLECombineKit

open class MockBLECentralManager: BLECentralManager, @unchecked Sendable {

    public init() { }

    public var stateSubject = CurrentValueSubject<CBManagerState, Never>(.unknown)
    public var state: AnyPublisher<CBManagerState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    public var associatedCentralManager: CBCentralManagerWrapper = MockCBCentralManagerWrapper()

    public var isScanningValue: Bool = false
    public var isScanning: Bool {
        isScanningValue
    }

    public var retrievePeripheralsReturnValue: AnyPublisher<BLEPeripheral, BLEError> = Empty().eraseToAnyPublisher()
    public var retrievePeripheralsWasCalledCount = 0
    public var retrievePeripheralsIdentifiers = [UUID]()
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheral, BLEError> {
        retrievePeripheralsWasCalledCount += 1
        retrievePeripheralsIdentifiers = identifiers
        return retrievePeripheralsReturnValue
    }

    public var retrieveConnectedPeripheralsReturnValue: AnyPublisher<BLEPeripheral, BLEError> = Empty().eraseToAnyPublisher()
    public var retrieveConnectedPeripheralsWasCalledCount = 0
    public var retrieveConnectedPeripheralsServiceUUIDs = [CBUUID]()
    public func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheral, BLEError> {
        retrieveConnectedPeripheralsWasCalledCount += 1
        retrieveConnectedPeripheralsServiceUUIDs = serviceUUIDs
        return retrieveConnectedPeripheralsReturnValue
    }

    public var scanForPeripheralsReturnValue: AnyPublisher<BLEScanResult, BLEError> = Empty().eraseToAnyPublisher()
    public var scanForPeripheralsWasCalledCount = 0
    public var scanForPeripheralsServices: [CBUUID]?
    public var scanForPeripheralsOptions: [String: Any]?
    public func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<BLEScanResult, BLEError> {
        scanForPeripheralsWasCalledCount += 1
        scanForPeripheralsServices = services
        scanForPeripheralsOptions = options
        return scanForPeripheralsReturnValue
    }

    public var stopScanWasCalledCount = 0
    public func stopScan() {
        stopScanWasCalledCount += 1
    }

    public var connectReturnValue: AnyPublisher<BLEPeripheral, BLEError> = Empty().eraseToAnyPublisher()
    public var connectWasCalledCount = 0
    public var connectPeripheral: BLEPeripheral?
    public var connectOptions: [String: Any]?
    public func connect(peripheral: BLEPeripheral, options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
        connectWasCalledCount += 1
        connectPeripheral = peripheral
        connectOptions = options
        return connectReturnValue
    }

    public var cancelPeripheralConnectionReturnValue: AnyPublisher<Never, Never> = Empty().eraseToAnyPublisher()
    public var cancelPeripheralConnectionWasCalledCount = 0
    public var cancelPeripheralConnectionPeripheral: BLEPeripheral?
    public func cancelPeripheralConnection(_ peripheral: BLEPeripheral) -> AnyPublisher<Never, Never> {
        cancelPeripheralConnectionWasCalledCount += 1
        cancelPeripheralConnectionPeripheral = peripheral
        return cancelPeripheralConnectionReturnValue
    }

    public var registerForConnectionEventsWasCalledCount = 0
    public var registerForConnectionEventsOptions: [CBConnectionEventMatchingOption: Any]?
    public func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?) {
        registerForConnectionEventsWasCalledCount += 1
        registerForConnectionEventsOptions = options
    }

    public var observeWillRestoreStateReturnValue: AnyPublisher<[String: Any], Never> = Empty().eraseToAnyPublisher()
    public var observeWillRestoreStateWasCalledCount = 0
    public func observeWillRestoreState() -> AnyPublisher<[String: Any], Never> {
        observeWillRestoreStateWasCalledCount += 1
        return observeWillRestoreStateReturnValue
    }

    public var observeDidUpdateANCSAuthorizationReturnValue: AnyPublisher<BLEPeripheral, Never> = Empty().eraseToAnyPublisher()
    public var observeDidUpdateANCSAuthorizationWasCalledCount = 0
    public func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never> {
        observeDidUpdateANCSAuthorizationWasCalledCount += 1
        return observeDidUpdateANCSAuthorizationReturnValue
    }
}
