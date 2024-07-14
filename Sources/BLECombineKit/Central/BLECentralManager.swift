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

/// Interface definining the Bluetooth Central Manager that provides Combine APIs.
public protocol BLECentralManager: AnyObject {
    /// Reference to the actual Bluetooth Manager, which is conveniently wrapped.
    var associatedCentralManager: CBCentralManagerWrapper { get }
  
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
  
    /// Connect to a peripheral with some options.
    func connect(peripheral: BLEPeripheral, options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError>
  
    /// Cancel a peripheral connection.
    func cancelPeripheralConnection(_ peripheral: BLEPeripheral) -> AnyPublisher<Never, Never>
    
    /// Register for any connection events.
    #if !os(macOS)
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?)
    #endif
  
    /// Observe for any changes to the willRestoreState.
    /// This method will generate an event for each update to willRestoreState, if any.
    func observeWillRestoreState() -> AnyPublisher<[String: Any], Never>
  
    /// Observe any update to the ANCS authorization.
    /// This method will trigger an event for any call to the delegate method
    /// `didUpdateANCSAuthorizationFor`.
    func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never>
}

final class StandardBLECentralManager: BLECentralManager {
    
    let associatedCentralManager: CBCentralManagerWrapper
    let peripheralProvider: BLEPeripheralProvider
    
    var stateSubject = CurrentValueSubject<ManagerState, Never>(ManagerState.unknown)
    let delegate: BLECentralManagerDelegate
    
    private var cancellables = [AnyCancellable]()
    
    var isScanning: Bool {
        associatedCentralManager.isScanning
    }
    
    var state: AnyPublisher<ManagerState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    init(
        centralManager: CBCentralManagerWrapper,
        managerDelegate: BLECentralManagerDelegate = BLECentralManagerDelegate(),
        peripheralProvider: BLEPeripheralProvider = StandardBLEPeripheralProvider()
    ) {
        self.associatedCentralManager = centralManager
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
            .ignoreFailure()
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
        let retrievedPeripherals = associatedCentralManager.retrievePeripherals(withIdentifiers: identifiers)
        return observePeripherals(from: retrievedPeripherals)
    }
    
    public func retrieveConnectedPeripherals(
      withServices serviceUUIDs: [CBUUID]
    ) -> AnyPublisher<BLEPeripheral, BLEError> {
        let retrievedPeripherals = associatedCentralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs)
        return observePeripherals(from: retrievedPeripherals)
    }
    
    public func scanForPeripherals(
      withServices services: [CBUUID]?,
      options: [String: Any]?
    ) -> AnyPublisher<BLEScanResult, BLEError> {
        associatedCentralManager.scanForPeripherals(withServices: services, options: options)
        
        return self.delegate
            .didDiscoverAdvertisementData
            .tryMap { [weak self] peripheral, advertisementData, rssi in
                guard let self else { throw BLEError.deallocated }
                let peripheral = self.peripheralProvider.provide(
                  for: peripheral,
                  centralManager: self
                )
                
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
        associatedCentralManager.stopScan()
    }
    
    public func connect(
      peripheral: BLEPeripheral,
      options: [String: Any]?
    ) -> AnyPublisher<BLEPeripheral, BLEError>  {
        associatedCentralManager.connect(peripheral.associatedPeripheral, options: options)
      
        // TODO: merge with didFailToConnect.
        return delegate
          .didConnectPeripheral
          .setFailureType(to: BLEError.self)
          .tryMap { [weak self] wrappedPeripheral in
            guard let self else { throw BLEError.deallocated }
            let peripheral = self.peripheralProvider.provide(
              for: wrappedPeripheral,
              centralManager: self
            )
            return peripheral
          }
          .mapError { $0 as? BLEError ?? BLEError.unknown}
          .eraseToAnyPublisher()
    }
    
    public func cancelPeripheralConnection(
      _ peripheral: BLEPeripheral
    ) -> AnyPublisher<Never, Never> {
        let associatedPeripheral = peripheral.associatedPeripheral
        associatedCentralManager.cancelPeripheralConnection(associatedPeripheral)
        
        return delegate.didDisconnectPeripheral
        .filter { $0.identifier == associatedPeripheral.identifier }
            .first()
            .ignoreOutput()
            .ignoreFailure()
            .eraseToAnyPublisher()
    }
    
    #if !os(macOS)
    public func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
        associatedCentralManager.registerForConnectionEvents(options: options)
    }
    #endif
    
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
