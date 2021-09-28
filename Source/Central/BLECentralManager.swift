//
//  BLECentralManager.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine
import CombineExt

public protocol BLECentralManager: AnyObject {
    var centralManager: CBCentralManagerWrapper { get }
    var isScanning: Bool { get }
    var state: AnyPublisher<ManagerState, Never> { get }
    
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheral, BLEError>
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheral, BLEError>
    func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<BLEScanResult, BLEError>
    func stopScan()
    func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?)
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) -> AnyPublisher<Never, Never>
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?)
    func observeWillRestoreState() -> AnyPublisher<[String: Any], Never>
    func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never>
}

final class StandardBLECentralManager: BLECentralManager {
    
    let centralManager: CBCentralManagerWrapper
    let peripheralProvider: BLEPeripheralProvider
    
    var stateSubject = CurrentValueSubject<ManagerState, Never>(ManagerState.unknown)
    let delegate: BLECentralManagerDelegate
    
    private var cancellables = [AnyCancellable]()
    
    private var connectedPeripherals: [UUID: BLETrackedPeripheral] = [:]
    
    var isScanning: Bool {
        centralManager.isScanning
    }
    
    var state: AnyPublisher<ManagerState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    init(
        centralManager: CBCentralManagerWrapper,
        managerDelegate: BLECentralManagerDelegate = BLECentralManagerDelegate(),
        peripheralProvider: BLEPeripheralProvider = StandardBLEPeripheralProvider()
    ) {
        self.centralManager = centralManager
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
    
    private func observeUpdateState() {
        delegate
            .didUpdateState
            .sink { state in
                self.stateSubject.send(state)
                for p in self.connectedPeripherals.values {
                    p.connectionState.send(false)
                }
                self.connectedPeripherals.removeAll()
            }
            .store(in: &cancellables)
    }
    
    func observeDidConnectPeripheral() {
        delegate
            .didConnectPeripheral
            .sink { [weak self] result in
                guard let self = self else { return }
                let p = self.peripheralProvider.provide(for: result, centralManager: self)
                p.connectionState.send(true)
                self.connectedPeripherals[p.peripheral.identifier] = p
            }.store(in: &cancellables)
    }
    
    func observeDidDisconnectPeripheral() {
        delegate
            .didDisconnectPeripheral
            .sink { [weak self] result in
                guard let self = self else { return }
                let p = self.peripheralProvider.provide(for: result, centralManager: self)
                p.connectionState.send(false)
                self.connectedPeripherals[p.peripheral.identifier] = nil
            }.store(in: &cancellables)
    }
    
    private func waitUntilPoweredOn() -> AnyPublisher<CBCentralManagerWrapper, BLEError> {
        if self.stateSubject.value == .poweredOn {
            return Just(centralManager).setFailureType(to: BLEError.self).eraseToAnyPublisher()
        } else {
            return self.stateSubject
                .filter({ $0 == .poweredOn })
                .first()
                .map { _ in self.centralManager }
                .setFailureType(to: BLEError.self)
                .eraseToAnyPublisher()
        }
    }
    
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheral, BLEError> {
        return waitUntilPoweredOn().flatMap { wrapper -> AnyPublisher<BLEPeripheral, BLEError> in
            let retrievedPeripherals = wrapper.retrievePeripherals(withIdentifiers: identifiers)
            return self.observePeripherals(from: retrievedPeripherals)
        }.eraseToAnyPublisher()
    }
    
    public func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheral, BLEError> {
        return waitUntilPoweredOn().flatMap { wrapper -> AnyPublisher<BLEPeripheral, BLEError> in
            let retrievedPeripherals = wrapper.retrieveConnectedPeripherals(withServices: serviceUUIDs)
            return self.observePeripherals(from: retrievedPeripherals)
        }.eraseToAnyPublisher()
    }
    
    public func scanForPeripherals(withServices services: [CBUUID]?,
                                   options: [String: Any]?) -> AnyPublisher<BLEScanResult, BLEError> {
        self.centralManager.scanForPeripherals(withServices: services, options: options)
        
        return self.delegate
            .didDiscoverAdvertisementData
            .tryMap { [weak self] peripheral, advertisementData, rssi in
                guard let self = self else { throw BLEError.deallocated }
                let peripheral = self.peripheralProvider.provide(for: peripheral, centralManager: self)
                
                return BLEScanResult(
                    peripheral: peripheral,
                    advertisementData: advertisementData,
                    rssi: rssi
                )
            }
            .mapError { $0 as? BLEError ?? BLEError.unknown}
            .eraseToAnyPublisher()
    }
    
    public func stopScan() {
        centralManager.stopScan()
    }
    
    public func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?) {
        centralManager.connect(peripheralWrapper, options: options)
    }
    
    public func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) -> AnyPublisher<Never, Never> {
        centralManager.cancelPeripheralConnection(peripheral)
        
        return delegate.didDisconnectPeripheral
            .filter { $0.identifier == peripheral.identifier }
            .first()
            .ignoreOutput()
            .ignoreFailure()
            .eraseToAnyPublisher()
    }
    
    public func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        centralManager.registerForConnectionEvents(options: options)
    }
    
    public func observeWillRestoreState() -> AnyPublisher<[String: Any], Never> {
        delegate.willRestoreState.eraseToAnyPublisher()
    }
    
    public func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never> {
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
        observeDidDisconnectPeripheral()
    }
    
    private func observePeripherals(from retrievedPeripherals: [CBPeripheralWrapper]) -> AnyPublisher<BLEPeripheral, BLEError>{
        let peripherals = retrievedPeripherals
            .compactMap { [weak self]  peripheral -> BLEPeripheral? in
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
