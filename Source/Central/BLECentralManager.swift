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

public protocol BLECentralManager {
    var centralManager: CBCentralManagerWrapper { get }
    var isScanning: Bool { get }
    
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheralProtocol, BLEError>
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheralProtocol, BLEError>
    func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<BLEScanResult, BLEError>
    func stopScan()
    func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?)
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) -> AnyPublisher<Bool, BLEError>
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?)
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
        
        if let centralManager = centralManager as? CBCentralManagerWrapperImpl {
            centralManager.setupDelegate(managerDelegate)
        }
        
        subscribeToDelegate()
    }
    
    convenience init(with centralManager: CBCentralManager) {
        let centralManagerWrapper = CBCentralManagerWrapperImpl(with: centralManager)
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
                if let scannedPeripheral = self.scannedPeripherals[result.identifier] {
                    scannedPeripheral.connectionState.send(true)
                }
            }
            .store(in: &cancellables)
    }
    
    func observeDidDisconnectPeripheral() {
        delegate
            .didDisconnectPeripheral
            .sink { [weak self] result in
                guard let self = self else { return }
                if let scannedPeripheral = self.scannedPeripherals[result.identifier] {
                    scannedPeripheral.connectionState.send(false)
                }
            }
            .store(in: &cancellables)
    }
    
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheralProtocol, BLEError> {
        let retrievedPeripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        return observePeripherals(from: retrievedPeripherals)
    }
    
    public func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheralProtocol, BLEError> {
        let retrievedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs)
        return observePeripherals(from: retrievedPeripherals)
    }
    
    public func scanForPeripherals(withServices services: [CBUUID]?,
                                   options: [String: Any]?) -> AnyPublisher<BLEScanResult, BLEError> {
        self.centralManager.scanForPeripherals(withServices: services, options: options)
        
        return self.delegate
            .didDiscoverAdvertisementData
            .tryMap { [weak self] peripheral, advertisementData, rssi in
                guard let self = self else { throw BLEError.deallocated }
                
                let peripheralDelegate = BLEPeripheralDelegate()
                if let peripheralWrapper = peripheral as? StandardCBPeripheralWrapper {
                    peripheralWrapper.setupDelegate(peripheralDelegate)
                }
                
                let blePeripheral = BLEPeripheral(peripheral: peripheral,
                                                  centralManager: self,
                                                  delegate: peripheralDelegate)
                let scanResult = BLEScanResult(peripheral: blePeripheral,
                                               advertisementData: advertisementData,
                                               rssi: rssi)
                
                self.scannedPeripherals[peripheral.identifier] = blePeripheral
                
                return scanResult
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
    
    func observePeripherals(from retrievedPeripherals: [CBPeripheralWrapper]) -> AnyPublisher<BLEPeripheralProtocol, BLEError>{
        let peripherals = retrievedPeripherals
            .compactMap { peripheral -> BLEPeripheral? in
                peripheralBuilder.build(from: peripheral, centralManager: self)
            }
        
        return Publishers.Sequence.init(sequence: peripherals)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private methods
    
    private func subscribeToDelegate() {
        observeUpdateState()
        observeDidConnectPeripheral()
        observeDidDisconnectPeripheral()
    }
    
}
