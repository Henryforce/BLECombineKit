//
//  MockBLEPeripheral.swift
//  BLECombineKitMocks
//
//  Created by Henry Javier Serrano Echeverria on 10/1/26.
//

import Combine
import CoreBluetooth
import Foundation
import BLECombineKit

open class MockBLEPeripheral: BLEPeripheral, @unchecked Sendable {

    public init() { }

    public var associatedPeripheral: CBPeripheralWrapper = MockCBPeripheralWrapper()

    public var observeConnectionStateReturnValue: AnyPublisher<Bool, Never> = Just(true).eraseToAnyPublisher()
    public var observeConnectionStateWasCalledCount = 0
    public func observeConnectionState() -> AnyPublisher<Bool, Never> {
        observeConnectionStateWasCalledCount += 1
        return observeConnectionStateReturnValue
    }

    public var connectReturnValue: AnyPublisher<BLEPeripheral, BLEError> = Empty().eraseToAnyPublisher()
    public var connectWasCalledCount = 0
    public var connectOptions: [String: Any]?
    public func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
        connectWasCalledCount += 1
        connectOptions = options
        return connectReturnValue
    }

    public var disconnectReturnValue: AnyPublisher<Never, BLEError> = Empty().eraseToAnyPublisher()
    public var disconnectWasCalledCount = 0
    public func disconnect() -> AnyPublisher<Never, BLEError> {
        disconnectWasCalledCount += 1
        return disconnectReturnValue
    }

    public var observeNameValueReturnValue: AnyPublisher<String, Never> = Empty().eraseToAnyPublisher()
    public var observeNameValueWasCalledCount = 0
    public func observeNameValue() -> AnyPublisher<String, Never> {
        observeNameValueWasCalledCount += 1
        return observeNameValueReturnValue
    }

    public var observeRSSIValueReturnValue: AnyPublisher<NSNumber, BLEError> = Empty().eraseToAnyPublisher()
    public var observeRSSIValueWasCalledCount = 0
    public func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
        observeRSSIValueWasCalledCount += 1
        return observeRSSIValueReturnValue
    }

    public var discoverServicesReturnValue: AnyPublisher<BLEService, BLEError> = Empty().eraseToAnyPublisher()
    public var discoverServicesWasCalledCount = 0
    public var discoverServicesUUIDs: [CBUUID]?
    public func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError> {
        discoverServicesWasCalledCount += 1
        discoverServicesUUIDs = serviceUUIDs
        return discoverServicesReturnValue
    }

    public var discoverCharacteristicsReturnValue: AnyPublisher<BLECharacteristic, BLEError> = Empty().eraseToAnyPublisher()
    public var discoverCharacteristicsWasCalledCount = 0
    public var discoverCharacteristicsUUIDs: [CBUUID]?
    public var discoverCharacteristicsService: CBService?
    public func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, BLEError> {
        discoverCharacteristicsWasCalledCount += 1
        discoverCharacteristicsUUIDs = characteristicUUIDs
        discoverCharacteristicsService = service
        return discoverCharacteristicsReturnValue
    }

    public var readValueReturnValue: AnyPublisher<BLEData, BLEError> = Empty().eraseToAnyPublisher()
    public var readValueWasCalledCount = 0
    public var readValueCharacteristic: CBCharacteristic?
    public func readValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        readValueWasCalledCount += 1
        readValueCharacteristic = characteristic
        return readValueReturnValue
    }

    public var observeValueReturnValue: AnyPublisher<BLEData, BLEError> = Empty().eraseToAnyPublisher()
    public var observeValueWasCalledCount = 0
    public var observeValueCharacteristic: CBCharacteristic?
    public func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        observeValueWasCalledCount += 1
        observeValueCharacteristic = characteristic
        return observeValueReturnValue
    }

    public var observeValueUpdateAndSetNotificationReturnValue: AnyPublisher<BLEData, BLEError> = Empty().eraseToAnyPublisher()
    public var observeValueUpdateAndSetNotificationWasCalledCount = 0
    public var observeValueUpdateAndSetNotificationCharacteristic: CBCharacteristic?
    public func observeValueUpdateAndSetNotification(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
        observeValueUpdateAndSetNotificationWasCalledCount += 1
        observeValueUpdateAndSetNotificationCharacteristic = characteristic
        return observeValueUpdateAndSetNotificationReturnValue
    }

    public var setNotifyValueWasCalledCount = 0
    public var setNotifyValueEnabled: Bool?
    public var setNotifyValueCharacteristic: CBCharacteristic?
    public func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        setNotifyValueWasCalledCount += 1
        setNotifyValueEnabled = enabled
        setNotifyValueCharacteristic = characteristic
    }

    public var writeValueReturnValue: AnyPublisher<Never, BLEError> = Empty().eraseToAnyPublisher()
    public var writeValueWasCalledCount = 0
    public var writeValueData: Data?
    public var writeValueCharacteristic: CBCharacteristic?
    public var writeValueType: CBCharacteristicWriteType?
    public func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) -> AnyPublisher<Never, BLEError> {
        writeValueWasCalledCount += 1
        writeValueData = data
        writeValueCharacteristic = characteristic
        writeValueType = type
        return writeValueReturnValue
    }
}
