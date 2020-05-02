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

public protocol BLEMainPeripheralProtocol { // Mockable peripheral
    var connectionState: CurrentValueSubject<Bool, Never> { get }
    var peripheral: CBPeripheralWrapper { get }

    func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError>
    func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError>
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, BLEError>
    func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>
    func observeValueUpdateAndSetNotification(for characteristicUUID: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>
    func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError>
}

// Internal class

final public class BLEPeripheral: BLEMainPeripheralProtocol {
    
    public let connectionState: CurrentValueSubject<Bool, Never>
    public let peripheral: CBPeripheralWrapper
    private let delegate: BLEPeripheralDelegate
    private let centralManager: BLECentralManagerProtocol?
    private var disposable = Set<AnyCancellable>()
    
    init(peripheral: CBPeripheralWrapper, centralManager: BLECentralManagerProtocol?, delegate: BLEPeripheralDelegate) {
        self.connectionState = CurrentValueSubject<Bool, Never>(false)
        self.peripheral = peripheral
        self.centralManager = centralManager
        self.delegate = delegate
    }
    
    public convenience init(peripheral: CBPeripheralWrapper, centralManager: BLECentralManagerProtocol?) {
        let delegate = BLEPeripheralDelegate()
        if let peripheral = peripheral as? CBPeripheralWrapperImpl {
            peripheral.setupDelegate(delegate)
        }
        self.init(peripheral: peripheral, centralManager: centralManager, delegate: delegate)
    }
    
    public func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
        centralManager?.connect(peripheralWrapper: peripheral, options: options)

        return connectionState
            .filter { $0 == true }
            .map { _ in self }
            .mapError { _ in BLEError.connectionFailure }
            .eraseToAnyPublisher()
    }
    
    public func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError> {
        
        let servicesMap = createUUIDsMap(from: serviceUUIDs)
        let serviceSubject = PassthroughSubject<BLEService, BLEError>()
        
        self.delegate
            .didDiscoverServices
            .handleEvents { [weak self]  _ in
                guard let self = self else { return }
                self.peripheral.discoverServices(serviceUUIDs)
            }
            .tryFilter { [weak self] in
                guard let self = self else { throw BLEError.deallocated }
                return $0.identifier == self.peripheral.identifier
            }
            .sink(receiveCompletion: { event in
                print(event)
            }, receiveValue: { [weak self] peripheral in
                guard let self = self, let services = peripheral.services else { return }
                self.dispatchServices(from: services, and: servicesMap, in: serviceSubject)
            })
            .store(in: &disposable)
        
        return serviceSubject.eraseToAnyPublisher()
    }
    
    public func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, BLEError> {
        
        let characteristicsMap = createUUIDsMap(from: characteristicUUIDs)
        let characteristicSubject = PassthroughSubject<BLECharacteristic, BLEError>()
        
        self.delegate
            .didDiscoverCharacteristics
            .handleEvents { [weak self] _ in
                guard let self = self else { return }
                self.peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
            }
            .tryFilter { [weak self] in
                guard let self = self else { throw BLEError.deallocated }
                return $0.peripheral.identifier == self.peripheral.identifier
            }
            .sink(receiveCompletion: { event in
                print(event)
            }, receiveValue: { [weak self] result in
                guard let self = self, let characteristics = result.service.characteristics else { return }
                self.dispatchCharacteristics(from: characteristics, and: characteristicsMap, in: characteristicSubject)
            })
            .store(in: &disposable)
        
        return characteristicSubject.eraseToAnyPublisher()
    }
    
    public func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        let deferredPublisher = Deferred<AnyPublisher<BLEData, BLEError>> {
            return self.delegate
                .didUpdateValueForCharacteristic
                .tryFilter { $0.characteristic.uuid == characteristic.uuid }
                .tryMap { filteredPeripheral in
                    guard let data = filteredPeripheral.characteristic.value else { throw BLEError.invalidData }
                    return BLEData(value: data, peripheral: self)
                }
                .mapError { $0 as? BLEError ?? BLEError.unknown }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
        
        return deferredPublisher
    }
    
    public func observeValueUpdateAndSetNotification(for characteristicUUID: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        return observeValue(for: characteristicUUID)
            .handleEvents { [weak self] _ in
                guard let self = self else { return }
                self.peripheral.setNotifyValue(true, for: characteristicUUID)
            }
            .eraseToAnyPublisher()
    }

    public func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
        // todo: read rssi
        return delegate
            .didReadRSSI
            .map { $0.rssi }
            .mapError { $0 as? BLEError ?? BLEError.unknown }
            .eraseToAnyPublisher()
    }
    
    func createUUIDsMap(from uuids:[CBUUID]?) -> [CBUUID: Bool]? {
        var characteristicsMap: [CBUUID: Bool]?
        if let uuids = uuids {
            characteristicsMap = [:]
            uuids.forEach({ cbuuid in
                characteristicsMap?[cbuuid] = true
            })
        }
        return characteristicsMap
    }
    
    func dispatchServices(from services: [CBService],
                          and servicesMap: [CBUUID: Bool]?,
                          in publisher: PassthroughSubject<BLEService, BLEError>) {
        services
            .filter { service in
                guard let services = servicesMap else { return true }
                return services[service.uuid] ?? false
            }
            .map { BLEService(value: $0, peripheral: self) }
            .forEach { publisher.send($0) }
    }
    
    func dispatchCharacteristics(from characteristics: [CBCharacteristic],
                                 and characteristicsMap: [CBUUID: Bool]?,
                                 in publisher: PassthroughSubject<BLECharacteristic, BLEError>) {
        characteristics
            .filter { characteristic in
                guard let characteristics = characteristicsMap else { return true }
                return characteristics[characteristic.uuid] ?? false
            }
            .map { BLECharacteristic(value: $0, peripheral: self) }
            .forEach { publisher.send($0) }
    }
    
}
