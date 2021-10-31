//
//  StandardBLEPeripheral.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 6/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth

final public class StandardBLEPeripheral: BLETrackedPeripheral {
    
    let connectionState = CurrentValueSubject<Bool, Never>(false)
    public let peripheral: CBPeripheralWrapper
    private let delegate: BLEPeripheralDelegate
    private weak var centralManager: BLECentralManager?
    private var connectCancellable: AnyCancellable?
    private var discoverServicesCancellable: AnyCancellable?
    private var discoverCharacteristicsCancellable: AnyCancellable?
    
    init(
        peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager?,
        delegate: BLEPeripheralDelegate
    ) {
        self.peripheral = peripheral
        self.centralManager = centralManager
        self.delegate = delegate
    }
    
    public convenience init(
        peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager?
    ) {
        let delegate = BLEPeripheralDelegate()
        if let peripheral = peripheral as? StandardCBPeripheralWrapper {
            peripheral.setupDelegate(delegate)
        }
        self.init(peripheral: peripheral, centralManager: centralManager, delegate: delegate)
    }
    
    public func observeConnectionState() -> AnyPublisher<Bool, Never> {
        return connectionState.eraseToAnyPublisher()
    }
    
    public func connect(
        with options: [String: Any]?
    ) -> AnyPublisher<BLEPeripheral, BLEError> {
        centralManager?.connect(peripheralWrapper: peripheral, options: options)
        connectCancellable?.cancel()
        return Future<BLEPeripheral, BLEError> { [weak self] promise in
            guard let self = self else { return }
            self.connectCancellable = self.connectionState
                .filter { $0 == true }
                .tryMap { [weak self] _ -> BLEPeripheral in
                    guard let self = self else { throw BLEError.deallocated }
                    return self
                }.sink(receiveCompletion: { completion in
                    guard case .failure = completion else { return }
                    promise(.failure(BLEError.peripheral(.connectionFailure)))
                }, receiveValue: { value in
                    promise(.success(value))
                })
        }.eraseToAnyPublisher()
    }
    
    @discardableResult
    public func disconnect() -> AnyPublisher<Never, BLEError> {
        guard let centralManager = centralManager else {
            return Just.init(false)
                .tryMap { _ in throw BLEError.peripheral(.disconnectionFailed) }
                .mapError { $0 as? BLEError ?? BLEError.unknown }
                .eraseToAnyPublisher()
        }
        return centralManager
            .cancelPeripheralConnection(peripheral)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
    }
    
    public func observeNameValue() -> AnyPublisher<String, Never> {
        return delegate
            .didUpdateName
            .map({ $1 })
            .eraseToAnyPublisher()
    }
    
    public func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
        peripheral.readRSSI()
        
        return delegate
            .didReadRSSI
            .map { $0.rssi }
            .mapError { $0 as? BLEError ?? BLEError.unknown }
            .eraseToAnyPublisher()
    }
    
    public func discoverServices(
        serviceUUIDs: [CBUUID]?
    ) -> AnyPublisher<BLEService, BLEError> {
        let subject = PassthroughSubject<BLEService, BLEError>()
        
        if let services = peripheral.services, services.isNotEmpty {
            return Publishers.Sequence.init(sequence: services)
                .setFailureType(to: BLEError.self)
                .map { BLEService(value: $0, peripheral: self) }
                .eraseToAnyPublisher()
        }

        peripheral.discoverServices(serviceUUIDs)
        discoverServicesCancellable?.cancel()
        
        discoverServicesCancellable = delegate
            .didDiscoverServices
            .tryFilter { [weak self] in
                guard let self = self else { throw BLEError.deallocated }
                return $0.peripheral.identifier == self.peripheral.identifier
            }
            .tryMap { result -> [CBService] in
                guard result.error == nil, let services = result.peripheral.services else { throw BLEError.peripheral(.servicesFoundError(BLEError.CoreBluetoothError.from(error: result.error! as NSError))) }
                return services
            }
            .mapError { $0 as? BLEError ?? BLEError.unknown }
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else { return }
                subject.send(completion: .failure(error))
            }, receiveValue: { [weak self] services in
                guard let self = self else { return }
                services.forEach { service in
                    subject.send(BLEService(value: service, peripheral: self))
                }
                subject.send(completion: .finished)
            })
        
        return subject.eraseToAnyPublisher()
    }
    
    public func discoverCharacteristics(
        characteristicUUIDs: [CBUUID]?,
        for service: CBService
    ) -> AnyPublisher<BLECharacteristic, BLEError> {
        let subject = PassthroughSubject<BLECharacteristic, BLEError>()
        peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        discoverCharacteristicsCancellable?.cancel()
        
        discoverCharacteristicsCancellable = delegate
            .didDiscoverCharacteristics
            .tryFilter { [weak self] in
                guard let self = self else { throw BLEError.deallocated }
                return $0.peripheral.identifier == self.peripheral.identifier
            }
            .tryMap { result -> [CBCharacteristic] in
                guard result.error == nil, let characteristics = result.service.characteristics else { throw BLEError.peripheral(.characteristicsFoundError(BLEError.CoreBluetoothError.from(error: result.error! as NSError))) }
                return characteristics
            }
            .mapError { $0 as? BLEError ?? BLEError.unknown }
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else { return }
                subject.send(completion: .failure(error))
            }, receiveValue: { [weak self] characteristics in
                guard let self = self else { return }
                characteristics.forEach { characteristic in
                    subject.send(BLECharacteristic(value: characteristic, peripheral: self))
                }
                subject.send(completion: .finished)
            })
        
        return subject.eraseToAnyPublisher()
    }
    
    public func observeValue(
        for characteristic: CBCharacteristic
    ) -> AnyPublisher<BLEData, BLEError> {
        buildDeferredValuePublisher(for: characteristic)
            .handleEvents(receiveRequest:  { [weak self] _ in
                self?.peripheral.readValue(for: characteristic)
            }).eraseToAnyPublisher()
    }
    
    public func observeValueUpdateAndSetNotification(
        for characteristic: CBCharacteristic
    ) -> AnyPublisher<BLEData, BLEError> {
        buildDeferredValuePublisher(for: characteristic)
            .handleEvents(receiveRequest:  { [weak self] _ in
                self?.peripheral.setNotifyValue(true, for: characteristic)
            }).eraseToAnyPublisher()
    }
    
    public func setNotifyValue(
        _ enabled: Bool,
        for characteristic: CBCharacteristic
    ) {
        peripheral.setNotifyValue(false, for: characteristic)
    }
    
    public func writeValue(
        _ data: Data,
        for characteristic: CBCharacteristic,
        type: CBCharacteristicWriteType
    ) -> AnyPublisher<Never, BLEError> {
        defer {
            peripheral.writeValue(data, for: characteristic, type: type)
        }
        
        switch type {
        case .withResponse:
            return self.delegate
                .didWriteValueForCharacteristic
                .filter({ $0.characteristic == characteristic })
                .tryMap({ result -> CBCharacteristic in
                    if let error = result.error {
                        throw error
                    }
                    return result.characteristic
                })
                .mapError({ BLEError.writeFailed(BLEError.CoreBluetoothError.from(error:
                                                $0 as NSError)) })
                .first()
                .ignoreOutput()
                .eraseToAnyPublisher()
        default:
            return Empty(completeImmediately: true)
                .setFailureType(to: BLEError.self)
                .eraseToAnyPublisher()
        }
    }
    
    func buildDeferredValuePublisher(
        for characteristic: CBCharacteristic
    ) -> AnyPublisher<BLEData, BLEError> {
        Deferred<AnyPublisher<BLEData, BLEError>> {
            self.delegate
                .didUpdateValueForCharacteristic
                .filter { $0.characteristic.uuid == characteristic.uuid }
                .tryMap { [weak self] filteredPeripheral in
                    guard let self = self else { throw BLEError.deallocated }
                    guard let data = filteredPeripheral.characteristic.value else { throw BLEError.data(.invalid) }
                    return BLEData(value: data, peripheral: self)
                }
                .mapError { $0 as? BLEError ?? BLEError.unknown }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
}
