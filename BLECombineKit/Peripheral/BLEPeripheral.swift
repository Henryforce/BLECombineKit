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
    func observeValueUpdateAndSetNotification(for characteristicUUID: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) -> AnyPublisher<Bool, BLEError>
}

// Internal class

final public class BLEPeripheral: BLEPeripheralProtocol {
    
    public let connectionState: CurrentValueSubject<Bool, Never>
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
//        let servicesMap = createUUIDsMap(from: serviceUUIDs)
//        let serviceSubject = PassthroughSubject<BLEService, BLEError>()
//
//        self.delegate
//            .didDiscoverServices
//            .handleEvents { [weak self]  _ in
//                guard let self = self else { return }
//                self.peripheral.discoverServices(serviceUUIDs)
//            }
//            .tryFilter { [weak self] in
//                guard let self = self else { throw BLEError.deallocated }
//                return $0.identifier == self.peripheral.identifier
//            }
//            .sink(receiveCompletion: { event in
//                print(event)
//            }, receiveValue: { [weak self] peripheral in
//                guard let self = self, let services = peripheral.services else { return }
//                self.dispatchServices(from: services, and: servicesMap, in: serviceSubject)
//            })
//            .store(in: &disposable)
//
//        return serviceSubject.eraseToAnyPublisher()
        
        return delegate
            .didDiscoverServices
            .handleEvents { [weak self]  _ in
               guard let self = self else { return }
               self.peripheral.discoverServices(serviceUUIDs)
            }
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
//
//        let characteristicsMap = createUUIDsMap(from: characteristicUUIDs)
//        let characteristicSubject = PassthroughSubject<BLECharacteristic, BLEError>()
//
//        self.delegate
//            .didDiscoverCharacteristics
//            .handleEvents { [weak self] _ in
//                guard let self = self else { return }
//                self.peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
//            }
//            .tryFilter { [weak self] in
//                guard let self = self else { throw BLEError.deallocated }
//                return $0.peripheral.identifier == self.peripheral.identifier
//            }
//            .sink(receiveCompletion: { event in
//                print(event)
//            }, receiveValue: { [weak self] result in
//                guard let self = self, let characteristics = result.service.characteristics else { return }
//                self.dispatchCharacteristics(from: characteristics, and: characteristicsMap, in: characteristicSubject)
//            })
//            .store(in: &disposable)
//
//        return characteristicSubject.eraseToAnyPublisher()
        
        return delegate
            .didDiscoverCharacteristics
            .handleEvents { [weak self]  _ in
               guard let self = self else { return }
               self.peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
            }
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
    
    public func observeValueUpdateAndSetNotification(for characteristicUUID: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        return buildDeferredValuePublisher(for: characteristicUUID)
            .handleEvents { [weak self] _ in
                guard let self = self else { return }
                self.peripheral.setNotifyValue(true, for: characteristicUUID)
            }.eraseToAnyPublisher()
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
    
//    func createUUIDsMap(from uuids:[CBUUID]?) -> [CBUUID: Bool]? {
//        var characteristicsMap: [CBUUID: Bool]?
//        if let uuids = uuids {
//            characteristicsMap = [:]
//            uuids.forEach({ cbuuid in
//                characteristicsMap?[cbuuid] = true
//            })
//        }
//        return characteristicsMap
//    }
//
//    func dispatchServices(from services: [CBService],
//                          and servicesMap: [CBUUID: Bool]?,
//                          in publisher: PassthroughSubject<BLEService, BLEError>) {
//        services
//            .filter { service in
//                guard let services = servicesMap else { return true }
//                return services[service.uuid] ?? false
//            }
//            .map { BLEService(value: $0, peripheral: self) }
//            .forEach { publisher.send($0) }
//    }
//
//    func dispatchCharacteristics(from characteristics: [CBCharacteristic],
//                                 and characteristicsMap: [CBUUID: Bool]?,
//                                 in publisher: PassthroughSubject<BLECharacteristic, BLEError>) {
//        characteristics
//            .filter { characteristic in
//                guard let characteristics = characteristicsMap else { return true }
//                return characteristics[characteristic.uuid] ?? false
//            }
//            .map { BLECharacteristic(value: $0, peripheral: self) }
//            .forEach { publisher.send($0) }
//    }
    
}
