//
//  BLEPeripheral.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

public protocol BLEPeripheralProtocol {
    var peripheral: CBPeripheralWrapper { get }

    func observeConnectionState() -> AnyPublisher<Bool, Never>
    func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError>
    func disconnect() -> AnyPublisher<Bool, BLEError>
    func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError>
    func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError>
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, BLEError>
    func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>
    func observeValueUpdateAndSetNotification(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic)
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) -> AnyPublisher<Bool, BLEError>
}

final public class BLEPeripheral: BLEPeripheralProtocol {
    
    let connectionState: CurrentValueSubject<Bool, Never>
    public let peripheral: CBPeripheralWrapper
    private let delegate: BLEPeripheralDelegate
    private let centralManager: BLECentralManager?
    private var disposable = Set<AnyCancellable>()
    
    init(peripheral: CBPeripheralWrapper, centralManager: BLECentralManager?, delegate: BLEPeripheralDelegate) {
        self.connectionState = CurrentValueSubject<Bool, Never>(false)
        self.peripheral = peripheral
        self.centralManager = centralManager
        self.delegate = delegate
    }
    
    public convenience init(peripheral: CBPeripheralWrapper, centralManager: BLECentralManager?) {
        let delegate = BLEPeripheralDelegate()
        if let peripheral = peripheral as? CBPeripheralWrapperImpl {
            peripheral.setupDelegate(delegate)
        }
        self.init(peripheral: peripheral, centralManager: centralManager, delegate: delegate)
    }
    
    public func observeConnectionState() -> AnyPublisher<Bool, Never> {
        return connectionState.eraseToAnyPublisher()
    }
    
    public func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
        centralManager?.connect(peripheralWrapper: peripheral, options: options)

        return connectionState
            .filter { $0 == true }
            .map { _ in self }
            .mapError { _ in BLEError.connectionFailure }
            .eraseToAnyPublisher()
    }
    
    public func disconnect() -> AnyPublisher<Bool, BLEError> {
        guard let centralManager = centralManager else {
            return Just.init(false)
                .tryMap { _ in throw BLEError.disconnectionFailed }
                .mapError { $0 as? BLEError ?? BLEError.unknown }
                .eraseToAnyPublisher()
        }
        return centralManager.cancelPeripheralConnection(peripheral)
    }
    
    public func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
        peripheral.readRSSI()
        
        return delegate
            .didReadRSSI
            .map { $0.rssi }
            .mapError { $0 as? BLEError ?? BLEError.unknown }
            .eraseToAnyPublisher()
    }
    
    public func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError> {
        
        if let services = peripheral.services, !services.isEmpty {
            return Publishers.Sequence.init(sequence: services).setFailureType(to: BLEError.self)
                .map { BLEService(value: $0, peripheral: self) }
                .eraseToAnyPublisher()
        }
        
        peripheral.discoverServices(serviceUUIDs)
        
        return delegate
            .didDiscoverServices
            .tryFilter { [weak self] in
                guard let self = self else { throw BLEError.deallocated }
                return $0.peripheral.identifier == self.peripheral.identifier
            }
            .tryMap { result -> [CBService] in
                guard result.error == nil, let services = result.peripheral.services else { throw BLEError.servicesFoundError(result.error) }
                return services
            }
            .flatMap { services -> AnyPublisher<CBService, Error> in
                return Publishers.Sequence.init(sequence: services).eraseToAnyPublisher()
            }
            .mapError { $0 as? BLEError ?? BLEError.unknown }
            .map { BLEService(value: $0, peripheral: self) }
            .eraseToAnyPublisher()
    }
    
    public func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, BLEError> {
        peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        
        return delegate
            .didDiscoverCharacteristics
            .tryFilter { [weak self] in
                guard let self = self else { throw BLEError.deallocated }
                return $0.peripheral.identifier == self.peripheral.identifier
            }
            .tryMap { result -> [CBCharacteristic] in
                guard result.error == nil, let characteristics = result.service.characteristics else { throw BLEError.characteristicsFoundError(result.error) }
                return characteristics
            }
            .flatMap { characteristics -> AnyPublisher<CBCharacteristic, Error> in
                return Publishers.Sequence.init(sequence: characteristics).eraseToAnyPublisher()
            }
            .mapError { $0 as? BLEError ?? BLEError.unknown }
            .map { BLECharacteristic(value: $0, peripheral: self) }
            .eraseToAnyPublisher()
    }
    
    public func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        return buildDeferredValuePublisher(for: characteristic)
            .handleEvents { [weak self] _ in
                guard let self = self else { return }
                self.peripheral.readValue(for: characteristic)
            }.eraseToAnyPublisher()
    }
    
    public func observeValueUpdateAndSetNotification(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        return buildDeferredValuePublisher(for: characteristic)
            .handleEvents { [weak self] _ in
                guard let self = self else { return }
                self.peripheral.setNotifyValue(true, for: characteristic)
            }.eraseToAnyPublisher()
    }
    
    public func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        peripheral.setNotifyValue(false, for: characteristic)
    }
    
    public func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) -> AnyPublisher<Bool, BLEError> {
        peripheral.writeValue(data, for: characteristic, type: type)
        
        switch type {
        case .withResponse:
            return delegate
                .didWriteValueForCharacteristic
                .tryMap { result -> Bool in
                    if let error = result.error { throw BLEError.writeFailed(error) }
                    return result.characteristic == characteristic
                }
                .mapError { $0 as? BLEError ?? BLEError.unknown }
                .eraseToAnyPublisher()
        default:
            return Just.init(true).setFailureType(to: BLEError.self).eraseToAnyPublisher()
        }
    }
    
    func buildDeferredValuePublisher(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        return Deferred<AnyPublisher<BLEData, BLEError>> {
                return self.delegate
                    .didUpdateValueForCharacteristic
                    .filter { $0.characteristic.uuid == characteristic.uuid }
                    .tryMap { filteredPeripheral in
                        guard let data = filteredPeripheral.characteristic.value else { throw BLEError.invalidData }
                        return BLEData(value: data, peripheral: self)
                    }
                    .mapError { $0 as? BLEError ?? BLEError.unknown }
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
}
