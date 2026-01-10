//
//  MockCBCentralManagerWrapper.swift
//  BLECombineKitMocks
//
//  Created by Henry Javier Serrano Echeverria on 10/1/26.
//

import CoreBluetooth
import Foundation
import BLECombineKit

open class MockCBCentralManagerWrapper: CBCentralManagerWrapper, @unchecked Sendable {

    public init() { }

    public var wrappedManager: CBCentralManager?

    public var isScanningValue: Bool = false
    public var isScanning: Bool {
        isScanningValue
    }

    public var delegate: CBCentralManagerDelegate?

    public var setupDelegateWasCalledCount = 0
    public var setupDelegateDelegate: CBCentralManagerDelegate?
    public func setupDelegate(_ delegate: CBCentralManagerDelegate) {
        setupDelegateWasCalledCount += 1
        setupDelegateDelegate = delegate
        self.delegate = delegate
    }

    public var retrieveCBPeripheralsReturnValue: [CBPeripheralWrapper] = []
    public var retrieveCBPeripheralsWasCalledCount = 0
    public var retrieveCBPeripheralsIdentifiers = [UUID]()
    public func retrieveCBPeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper] {
        retrieveCBPeripheralsWasCalledCount += 1
        retrieveCBPeripheralsIdentifiers = identifiers
        return retrieveCBPeripheralsReturnValue
    }

    public var retrieveConnectedCBPeripheralsReturnValue: [CBPeripheralWrapper] = []
    public var retrieveConnectedCBPeripheralsWasCalledCount = 0
    public var retrieveConnectedCBPeripheralsServiceUUIDs = [CBUUID]()
    public func retrieveConnectedCBPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralWrapper] {
        retrieveConnectedCBPeripheralsWasCalledCount += 1
        retrieveConnectedCBPeripheralsServiceUUIDs = serviceUUIDs
        return retrieveConnectedCBPeripheralsReturnValue
    }

    public var scanForPeripheralsWasCalledCount = 0
    public var scanForPeripheralsServiceUUIDs: [CBUUID]?
    public var scanForPeripheralsOptions: [String: Any]?
    public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?) {
        scanForPeripheralsWasCalledCount += 1
        scanForPeripheralsServiceUUIDs = serviceUUIDs
        scanForPeripheralsOptions = options
    }

    public var stopScanWasCalledCount = 0
    public func stopScan() {
        stopScanWasCalledCount += 1
    }

    public var connectWasCalledCount = 0
    public var connectPeripheral: CBPeripheralWrapper?
    public var connectOptions: [String: Any]?
    public func connect(_ wrappedPeripheral: CBPeripheralWrapper, options: [String: Any]?) {
        connectWasCalledCount += 1
        connectPeripheral = wrappedPeripheral
        connectOptions = options
    }

    public var cancelPeripheralConnectionWasCalledCount = 0
    public var cancelPeripheralConnectionPeripheral: CBPeripheralWrapper?
    public func cancelPeripheralConnection(_ wrappedPeripheral: CBPeripheralWrapper) {
        cancelPeripheralConnectionWasCalledCount += 1
        cancelPeripheralConnectionPeripheral = wrappedPeripheral
    }

    public var registerForConnectionEventsWasCalledCount = 0
    public var registerForConnectionEventsOptions: [CBConnectionEventMatchingOption: Any]?
    public func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?) {
        registerForConnectionEventsWasCalledCount += 1
        registerForConnectionEventsOptions = options
    }
}
