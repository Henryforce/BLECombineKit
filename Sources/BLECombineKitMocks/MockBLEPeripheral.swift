//
//  MockBLEPeripheral.swift
//  BLECombineKitMocks
//
//  Created by Henry Javier Serrano Echeverria on 10/1/26.
//

import BLECombineKit
import Combine
import CoreBluetooth
import Foundation

/// A mock implementation of `BLEPeripheral` for testing purposes.
open class MockBLEPeripheral: BLEPeripheral, @unchecked Sendable {

  public init() {}

  /// The associated peripheral wrapper.
  public var associatedPeripheral: CBPeripheralWrapper = MockCBPeripheralWrapper()

  /// Return value for `observeConnectionState()`.
  public var observeConnectionStateReturnValue: AnyPublisher<Bool, Never> = Just(true)
    .eraseToAnyPublisher()
  /// Count of how many times `observeConnectionState()` was called.
  public var observeConnectionStateWasCalledCount = 0

  /// Mocks observing the connection state.
  public func observeConnectionState() -> AnyPublisher<Bool, Never> {
    observeConnectionStateWasCalledCount += 1
    return observeConnectionStateReturnValue
  }

  /// Return value for `connect(with:)`.
  public var connectReturnValue: AnyPublisher<BLEPeripheral, BLEError> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `connect(with:)` was called.
  public var connectWasCalledCount = 0
  /// The options passed to the last call of `connect(with:)`.
  public var connectOptions: [String: Any]?

  /// Mocks connecting to the peripheral.
  public func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
    connectWasCalledCount += 1
    connectOptions = options
    return connectReturnValue
  }

  /// Return value for `disconnect()`.
  public var disconnectReturnValue: AnyPublisher<Never, BLEError> = Empty().eraseToAnyPublisher()
  /// Count of how many times `disconnect()` was called.
  public var disconnectWasCalledCount = 0

  /// Mocks disconnecting from the peripheral.
  public func disconnect() -> AnyPublisher<Never, BLEError> {
    disconnectWasCalledCount += 1
    return disconnectReturnValue
  }

  /// Return value for `observeNameValue()`.
  public var observeNameValueReturnValue: AnyPublisher<String, Never> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `observeNameValue()` was called.
  public var observeNameValueWasCalledCount = 0

  /// Mocks observing the peripheral name.
  public func observeNameValue() -> AnyPublisher<String, Never> {
    observeNameValueWasCalledCount += 1
    return observeNameValueReturnValue
  }

  /// Return value for `observeRSSIValue()`.
  public var observeRSSIValueReturnValue: AnyPublisher<NSNumber, BLEError> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `observeRSSIValue()` was called.
  public var observeRSSIValueWasCalledCount = 0

  /// Mocks observing the RSSI value.
  public func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
    observeRSSIValueWasCalledCount += 1
    return observeRSSIValueReturnValue
  }

  /// Return value for `discoverServices(serviceUUIDs:)`.
  public var discoverServicesReturnValue: AnyPublisher<BLEService, BLEError> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `discoverServices(serviceUUIDs:)` was called.
  public var discoverServicesWasCalledCount = 0
  /// The UUIDs passed to the last call of `discoverServices(serviceUUIDs:)`.
  public var discoverServicesUUIDs: [CBUUID]?

  /// Mocks discovering services.
  public func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError> {
    discoverServicesWasCalledCount += 1
    discoverServicesUUIDs = serviceUUIDs
    return discoverServicesReturnValue
  }

  /// Return value for `discoverCharacteristics(characteristicUUIDs:for:)`.
  public var discoverCharacteristicsReturnValue: AnyPublisher<BLECharacteristic, BLEError> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `discoverCharacteristics(characteristicUUIDs:for:)` was called.
  public var discoverCharacteristicsWasCalledCount = 0
  /// The characterisic UUIDs passed to the last call of `discoverCharacteristics(characteristicUUIDs:for:)`.
  public var discoverCharacteristicsUUIDs: [CBUUID]?
  /// The service passed to the last call of `discoverCharacteristics(characteristicUUIDs:for:)`.
  public var discoverCharacteristicsService: CBService?

  /// Mocks discovering characteristics for a service.
  public func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService)
    -> AnyPublisher<BLECharacteristic, BLEError>
  {
    discoverCharacteristicsWasCalledCount += 1
    discoverCharacteristicsUUIDs = characteristicUUIDs
    discoverCharacteristicsService = service
    return discoverCharacteristicsReturnValue
  }

  /// Return value for `readValue(for:)`.
  public var readValueReturnValue: AnyPublisher<BLEData, BLEError> = Empty().eraseToAnyPublisher()
  /// Count of how many times `readValue(for:)` was called.
  public var readValueWasCalledCount = 0
  /// The characteristic passed to the last call of `readValue(for:)`.
  public var readValueCharacteristic: CBCharacteristic?

  /// Mocks reading a value for a characteristic.
  public func readValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
    readValueWasCalledCount += 1
    readValueCharacteristic = characteristic
    return readValueReturnValue
  }

  /// Return value for `observeValue(for:)`.
  public var observeValueReturnValue: AnyPublisher<BLEData, BLEError> = Empty()
    .eraseToAnyPublisher()
  /// Count of how many times `observeValue(for:)` was called.
  public var observeValueWasCalledCount = 0
  /// The characteristic passed to the last call of `observeValue(for:)`.
  public var observeValueCharacteristic: CBCharacteristic?

  /// Mocks observing value updates for a characteristic.
  public func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>
  {
    observeValueWasCalledCount += 1
    observeValueCharacteristic = characteristic
    return observeValueReturnValue
  }

  /// Return value for `observeValueUpdateAndSetNotification(for:)`.
  public var observeValueUpdateAndSetNotificationReturnValue: AnyPublisher<BLEData, BLEError> =
    Empty().eraseToAnyPublisher()
  /// Count of how many times `observeValueUpdateAndSetNotification(for:)` was called.
  public var observeValueUpdateAndSetNotificationWasCalledCount = 0
  /// The characteristic passed to the last call of `observeValueUpdateAndSetNotification(for:)`.
  public var observeValueUpdateAndSetNotificationCharacteristic: CBCharacteristic?

  /// Mocks observing value updates and setting notifications for a characteristic.
  public func observeValueUpdateAndSetNotification(for characteristic: CBCharacteristic)
    -> AnyPublisher<BLEData, BLEError>
  {
    observeValueUpdateAndSetNotificationWasCalledCount += 1
    observeValueUpdateAndSetNotificationCharacteristic = characteristic
    return observeValueUpdateAndSetNotificationReturnValue
  }

  /// Count of how many times `setNotifyValue(_:for:)` was called.
  public var setNotifyValueWasCalledCount = 0
  /// The enabled state passed to the last call of `setNotifyValue(_:for:)`.
  public var setNotifyValueEnabled: Bool?
  /// The characteristic passed to the last call of `setNotifyValue(_:for:)`.
  public var setNotifyValueCharacteristic: CBCharacteristic?

  /// Mocks setting notifications for a characteristic.
  public func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
    setNotifyValueWasCalledCount += 1
    setNotifyValueEnabled = enabled
    setNotifyValueCharacteristic = characteristic
  }

  /// Return value for `writeValue(_:for:type:)`.
  public var writeValueReturnValue: AnyPublisher<Never, BLEError> = Empty().eraseToAnyPublisher()
  /// Count of how many times `writeValue(_:for:type:)` was called.
  public var writeValueWasCalledCount = 0
  /// The data passed to the last call of `writeValue(_:for:type:)`.
  public var writeValueData: Data?
  /// The characteristic passed to the last call of `writeValue(_:for:type:)`.
  public var writeValueCharacteristic: CBCharacteristic?
  /// The write type passed to the last call of `writeValue(_:for:type:)`.
  public var writeValueType: CBCharacteristicWriteType?

  /// Mocks writing a value to a characteristic.
  public func writeValue(
    _ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType
  ) -> AnyPublisher<Never, BLEError> {
    writeValueWasCalledCount += 1
    writeValueData = data
    writeValueCharacteristic = characteristic
    writeValueType = type
    return writeValueReturnValue
  }
}
