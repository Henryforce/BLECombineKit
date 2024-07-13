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

/// Interface definining the Bluetooth Central Manager that provides Combine APIs.
public protocol BLECentralManager: AnyObject {
    // TODO: change type to be CBCentralManager?, no need to expose the wrapper.
    /// Reference to the actual Bluetooth Manager.
    var centralManager: CBCentralManagerWrapper { get }
  
    /// The latest scanning status.
    var isScanning: Bool { get }
  
    /// The current state as a publisher.
    var state: AnyPublisher<ManagerState, Never> { get }
    
    /// Retrieve peripherals given a set of identifiers.
    /// This method will generate events for any matching peripheral or an error.
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<BLEPeripheral, BLEError>
  
    /// Retrieve connected peripherals given a set of service identifiers.
    /// This method will generate events for any matching peripheral or an error.
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<BLEPeripheral, BLEError>
  
    /// Start scanning for peripherals given a set of service identifiers and options.
    /// This method will generate scan result events or an error.
    func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<BLEScanResult, BLEError>
  
    /// Stop scanning.
    func stopScan()
  
    // TODO: update method to accept a BLEPeripheral instead of a CBPeripheralWrapper and make
    // it return an event.
    func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?)
  
    // TODO: update method to accept a BLEPeripheral instead of a CBPeripheralWrapper.
    func cancelPeripheralConnection(_ peripheral: CBPeripheralWrapper) -> AnyPublisher<Never, Never>
    
    /// Register for any connection events.
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?)
  
    /// Observe for any changes to the willRestoreState.
    /// This method will generate an event for each update to willRestoreState, if any.
    func observeWillRestoreState() -> AnyPublisher<[String: Any], Never>
  
    /// Observe any update to the ANCS authorization.
    /// This method will trigger an event for any call to the delegate method
    /// `didUpdateANCSAuthorizationFor`.
    func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never>
}

final class StandardBLECentralManager: BLECentralManager {
    
    let centralManager: CBCentralManagerWrapper
    let peripheralProvider: BLEPeripheralProvider
    
    var stateSubject = CurrentValueSubject<ManagerState, Never>(ManagerState.unknown)
    let delegate: BLECentralManagerDelegate
    
    private var cancellables = [AnyCancellable]()
    
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
    
    func observeUpdateState() {
        delegate
            .didUpdateState
            .sink { self.stateSubject.send($0) }
            .store(in: &cancellables)
    }
    
    func observeDidConnectPeripheral() {
        delegate
            .didConnectPeripheral
            .sink { [weak self] result in
                guard let self = self else { return }
                self.peripheralProvider.provide(for: result, centralManager: self).connectionState.send(true)
            }.store(in: &cancellables)
    }
    
    func observeDidFailToConnectPeripheral() {
        delegate
            .didFailToConnect
            .sink { [weak self] result in
                guard let self = self else { return }
                self.peripheralProvider.provide(for: result, centralManager: self).connectionState.send(false)
            }.store(in: &cancellables)
    }
    
    func observeDidDisconnectPeripheral() {
        delegate
            .didDisconnectPeripheral
            .sink { [weak self] result in
                guard let self = self else { return }
                self.peripheralProvider.provide(for: result, centralManager: self).connectionState.send(false)
            }.store(in: &cancellables)
    }
    
    public func retrievePeripherals(
      withIdentifiers identifiers: [UUID]
    ) -> AnyPublisher<BLEPeripheral, BLEError> {
        let retrievedPeripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        return observePeripherals(from: retrievedPeripherals)
    }
    
    public func retrieveConnectedPeripherals(
      withServices serviceUUIDs: [CBUUID]
    ) -> AnyPublisher<BLEPeripheral, BLEError> {
        let retrievedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs)
        return observePeripherals(from: retrievedPeripherals)
    }
    
    public func scanForPeripherals(
      withServices services: [CBUUID]?,
      options: [String: Any]?
    ) -> AnyPublisher<BLEScanResult, BLEError> {
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
    
    public func cancelPeripheralConnection(
      _ peripheral: CBPeripheralWrapper
    ) -> AnyPublisher<Never, Never> {
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
        observeDidFailToConnectPeripheral()
        observeDidDisconnectPeripheral()
    }
    
    private func observePeripherals(
      from retrievedPeripherals: [CBPeripheralWrapper]
    ) -> AnyPublisher<BLEPeripheral, BLEError>{
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
