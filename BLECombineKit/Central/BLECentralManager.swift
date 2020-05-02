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

public protocol BLECentralManagerProtocol {
    func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError>
    func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?)
}

public final class BLECentralManager {
    
    public let manager: CBCentralManagerWrapper
    
    public var state = CurrentValueSubject<ManagerState, Never>(ManagerState.unknown)
    let delegate: BLECentralManagerDelegate
    
    private var scannedPeripherals = [UUID: BLEPeripheral]()
    private var cancellables = [AnyCancellable]()
    
    init(centralManager: CBCentralManagerWrapper,
        managerDelegate: BLECentralManagerDelegate = BLECentralManagerDelegate()) {
        self.manager = centralManager
        self.delegate = managerDelegate
        
        if let centralManager = centralManager as? CBCentralManagerWrapperImpl {
            centralManager.setupDelegate(managerDelegate)
        }
        
        subscribeToDelegate()
    }
    
    public convenience init(with centralManager: CBCentralManager) {
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
            .sink { [weak self] in
                self?.scannedPeripherals[$0.identifier]?.connectionState.send(true)
            }
            .store(in: &cancellables)
    }
    
    func observeDidDisconnectPeripheral() {
        delegate
            .didDisconnectPeripheral
            .sink { [weak self] in
                self?.scannedPeripherals[$0.identifier]?.connectionState.send(false)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private methods
    
    private func subscribeToDelegate() {
        observeUpdateState()
        observeDidConnectPeripheral()
        observeDidDisconnectPeripheral()
    }
    
}

// MARK: - CentralManagerProtocol

extension BLECentralManager: BLECentralManagerProtocol {
    
    public func scanForPeripherals(
        withServices services: [CBUUID]?,
        options: [String: Any]?
    ) -> AnyPublisher<BLEPeripheral, BLEError> {
            self.manager.scanForPeripherals(withServices: services, options: options)
            
            return self.delegate
                .didDiscoverAdvertisementData
                .tryMap { [weak self] peripheral, advertisementData, rssi in // TODO: use advData and rssi
                    guard let self = self else { throw BLEError.deallocated }
                    
                    let peripheralDelegate = BLEPeripheralDelegate()
                    if let peripheralWrapper = peripheral as? CBPeripheralWrapperImpl {
                        peripheralWrapper.setupDelegate(peripheralDelegate)
                    }
                    
                    let blePeripheral = BLEPeripheral(peripheral: peripheral, centralManager: self, delegate: peripheralDelegate)
                    
                    self.scannedPeripherals[peripheral.identifier] = blePeripheral
                    
                    return blePeripheral
                }
                .mapError { $0 as? BLEError ?? BLEError.unknown}
                .eraseToAnyPublisher()
    }
    
    public func connect(peripheralWrapper: CBPeripheralWrapper, options: [String:Any]?) {
        manager.connect(peripheralWrapper, options: options)
    }
    
}
