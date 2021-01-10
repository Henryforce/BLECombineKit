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
    
    var state = CurrentValueSubject<ManagerState, Never>(ManagerState.unknown)
    let delegate: BLECentralManagerDelegate
    
    private var scannedPeripherals = [UUID: BLEPeripheral]()
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
    
    func observeUpdateState() {
        delegate
            .didUpdateState
            .sink { self.state.send($0) }
            .store(in: &cancellables)
    }
    
    func observeDidConnectPeripheral() {
        delegate
            .didConnectPeripheral
            .sink { [weak self] result in
                guard let self = self else { return }
                if let scannedPeripheral = self.scannedPeripherals[result.identifier] as? BLEPeripheralState {
                    scannedPeripheral.connectionState.send(true)
                }
            }.store(in: &cancellables)
    }
    
    func observeDidDisconnectPeripheral() {
        delegate
            .didDisconnectPeripheral
            .sink { [weak self] result in
                guard let self = self else { return }
                if let scannedPeripheral = self.scannedPeripherals[result.identifier] as? BLEPeripheralState {
                    scannedPeripheral.connectionState.send(false)
                }
            }.store(in: &cancellables)
    }
    
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheral, BLEError> {
        let retrievedPeripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        return observePeripherals(from: retrievedPeripherals)
    }
    
    public func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheral, BLEError> {
        let retrievedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs)
        return observePeripherals(from: retrievedPeripherals)
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
                
                self.scannedPeripherals[peripheral.peripheral.identifier] = peripheral
                
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
                return self.peripheralBuilder.build(
                    from: peripheral,
                    centralManager: self
                )
            }
        
        return Publishers.Sequence.init(sequence: peripherals)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
}
