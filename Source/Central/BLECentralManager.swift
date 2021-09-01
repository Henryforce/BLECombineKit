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

public protocol BLECentralManager: AnyObject {
    var centralManager: CBCentralManagerWrapper { get }
    var isScanning: Bool { get }
    var state: AnyPublisher<ManagerState, Never> { get }
    
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheral, BLEError>
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheral, BLEError>
    func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<BLEScanResult, BLEError>
    func stopScan()
    func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?)
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) -> AnyPublisher<Bool, BLEError>
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?)
    func observeWillRestoreState() -> AnyPublisher<[String: Any], Never>
    func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never>
}

final class StandardBLECentralManager: BLECentralManager {
    
    let centralManager: CBCentralManagerWrapper
    let peripheralBuilder: BLEPeripheralBuilder
    
    private var _state = CurrentValueSubject<ManagerState, Never>(ManagerState.unknown)
    var state: AnyPublisher<ManagerState, Never> {
        _state.eraseToAnyPublisher()
    }
    let delegate: BLECentralManagerDelegate
    
    private var knownPeripherals = [UUID: BLEPeripheral]()
    private var cancellables = [AnyCancellable]()
    
    var isScanning: Bool {
        centralManager.isScanning
    }
    
    init(
        centralManager: CBCentralManagerWrapper,
        managerDelegate: BLECentralManagerDelegate = BLECentralManagerDelegate(),
        peripheralBuilder: BLEPeripheralBuilder = StandardBLEPeripheralBuilder()
    ) {
        self.centralManager = centralManager
        self.delegate = managerDelegate
        self.peripheralBuilder = peripheralBuilder
        
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
                self._state.send(state)
                if state != .poweredOn {
                    for peripheral in self.knownPeripherals.values {
                        if let peripheral = peripheral as? BLEPeripheralState, peripheral.connectionState.value {
                            peripheral.connectionState.send(false)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func observeDidConnectPeripheral() {
        delegate
            .didConnectPeripheral
            .sink { [weak self] result in
                guard let self = self else { return }
                if let knownPeripheral = self.knownPeripherals[result.identifier] as? BLEPeripheralState {
                    knownPeripheral.connectionState.send(true)
                }
            }.store(in: &cancellables)
    }
    
    func observeDidDisconnectPeripheral() {
        delegate
            .didDisconnectPeripheral
            .sink { [weak self] result in
                guard let self = self else { return }
                if let scannedPeripheral = self.knownPeripherals[result.identifier] as? BLEPeripheralState {
                    scannedPeripheral.connectionState.send(false)
                }
            }.store(in: &cancellables)
    }
    
    private func waitUntilPoweredOn() -> AnyPublisher<CBCentralManagerWrapper, BLEError> {
        if _state.value == .poweredOn {
            return Just(centralManager).setFailureType(to: BLEError.self).eraseToAnyPublisher()
        } else {
            return _state
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
            .compactMap { [weak self] peripheral, advertisementData, rssi -> (BLEPeripheral, [String: Any], NSNumber)? in
                guard let self = self, let blePeripheral = self.peripheralBuilder.build(
                    from: peripheral,
                    centralManager: self
                ) else { return nil }
                return (blePeripheral, advertisementData, rssi)
            }
            .tryMap { [weak self] peripheral, advertisementData, rssi in
                guard let self = self else { throw BLEError.deallocated }
                
                self.knownPeripherals[peripheral.peripheral.identifier] = peripheral
                
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
    
    public func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) -> AnyPublisher<Bool, BLEError> {
        centralManager.cancelPeripheralConnection(peripheral)
        
        return delegate.didDisconnectPeripheral
            .filter { $0.identifier == peripheral.identifier }
            .map { _ in true }
            .setFailureType(to: BLEError.self)
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
                return self.peripheralBuilder.build(from: peripheral, centralManager: self)
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
                let p = self.peripheralBuilder.build(
                    from: peripheral,
                    centralManager: self
                )
                self.knownPeripherals[peripheral.identifier] = p
                return p
            }
        
        return Publishers.Sequence.init(sequence: peripherals)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
}
