//
//  MockCBPeripheralWrapper.swift
//  BLECombineKitMocks
//
//  Created by Henry Javier Serrano Echeverria on 10/1/26.
//

import BLECombineKit
import CoreBluetooth
import Foundation

/// A mock implementation of `CBPeripheralWrapper` for testing purposes.
open class MockCBPeripheralWrapper: CBPeripheralWrapper, @unchecked Sendable {

  public init() {}

  /// The wrapped `CBPeripheral`.
  public var wrappedPeripheral: CBPeripheral?

  /// Flag to control the `state` property.
  public var stateValue: CBPeripheralState = .disconnected
  public var state: CBPeripheralState {
    stateValue
  }

  /// Flag to control the `identifier` property.
  public var identifierValue: UUID = UUID()
  public var identifier: UUID {
    identifierValue
  }

  /// Flag to control the `name` property.
  public var nameValue: String?
  public var name: String? {
    nameValue
  }

  /// Flag to control the `services` property.
  public var servicesValue: [CBService]?
  public var services: [CBService]? {
    servicesValue
  }

  /// Count of how many times `setupDelegate(_:)` was called.
  public var setupDelegateWasCalledCount = 0
  /// The delegate passed to the last call of `setupDelegate(_:)`.
  public var setupDelegateDelegate: CBPeripheralDelegate?

  /// Mocks setting up the delegate.
  public func setupDelegate(_ delegate: CBPeripheralDelegate) {
    setupDelegateWasCalledCount += 1
    setupDelegateDelegate = delegate
  }

  /// Count of how many times `connect(manager:)` was called.
  public var connectWasCalledCount = 0
  /// The manager passed to the last call of `connect(manager:)`.
  public var connectManager: CBCentralManager?

  /// Mocks connecting the peripheral.
  public func connect(manager: CBCentralManager) {
    connectWasCalledCount += 1
    connectManager = manager
  }

  /// Count of how many times `cancelConnection(manager:)` was called.
  public var cancelConnectionWasCalledCount = 0
  /// The manager passed to the last call of `cancelConnection(manager:)`.
  public var cancelConnectionManager: CBCentralManager?

  /// Mocks cancelling the connection.
  public func cancelConnection(manager: CBCentralManager) {
    cancelConnectionWasCalledCount += 1
    cancelConnectionManager = manager
  }

  /// Count of how many times `readRSSI()` was called.
  public var readRSSIWasCalledCount = 0

  /// Mocks reading the RSSI.
  public func readRSSI() {
    readRSSIWasCalledCount += 1
  }

  /// Count of how many times `discoverServices(_:)` was called.
  public var discoverServicesWasCalledCount = 0
  /// The UUIDs passed to the last call of `discoverServices(_:)`.
  public var discoverServicesUUIDs: [CBUUID]?

  /// Mocks discovering services.
  public func discoverServices(_ serviceUUIDs: [CBUUID]?) {
    discoverServicesWasCalledCount += 1
    discoverServicesUUIDs = serviceUUIDs
  }

  /// Count of how many times `discoverIncludedServices(_:for:)` was called.
  public var discoverIncludedServicesWasCalledCount = 0
  /// The UUIDs passed to the last call of `discoverIncludedServices(_:for:)`.
  public var discoverIncludedServicesUUIDs: [CBUUID]?
  /// The service passed to the last call of `discoverIncludedServices(_:for:)`.
  public var discoverIncludedServicesService: CBService?

  /// Mocks discovering included services.
  public func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) {
    discoverIncludedServicesWasCalledCount += 1
    discoverIncludedServicesUUIDs = includedServiceUUIDs
    discoverIncludedServicesService = service
  }

  /// Count of how many times `discoverCharacteristics(_:for:)` was called.
  public var discoverCharacteristicsWasCalledCount = 0
  /// The UUIDs passed to the last call of `discoverCharacteristics(_:for:)`.
  public var discoverCharacteristicsUUIDs: [CBUUID]?
  /// The service passed to the last call of `discoverCharacteristics(_:for:)`.
  public var discoverCharacteristicsService: CBService?

  /// Mocks discovering characteristics.
  public func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
    discoverCharacteristicsWasCalledCount += 1
    discoverCharacteristicsUUIDs = characteristicUUIDs
    discoverCharacteristicsService = service
  }

  /// Count of how many times `readValue(for:)` (characteristic) was called.
  public var readValueWasCalledCount = 0
  /// The characteristic passed to the last call of `readValue(for:)`.
  public var readValueCharacteristic: CBCharacteristic?

  /// Mocks reading a characteristic value.
  public func readValue(for characteristic: CBCharacteristic) {
    readValueWasCalledCount += 1
    readValueCharacteristic = characteristic
  }

  /// Return value for `maximumWriteValueLength(for:)`.
  public var maximumWriteValueLengthReturnValue: Int = 0
  /// Count of how many times `maximumWriteValueLength(for:)` was called.
  public var maximumWriteValueLengthWasCalledCount = 0
  /// The write type passed to the last call of `maximumWriteValueLength(for:)`.
  public var maximumWriteValueLengthType: CBCharacteristicWriteType?

  /// Mocks getting the maximum write value length.
  public func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
    maximumWriteValueLengthWasCalledCount += 1
    maximumWriteValueLengthType = type
    return maximumWriteValueLengthReturnValue
  }

  /// Count of how many times `writeValue(_:for:type:)` (characteristic) was called.
  public var writeValueWasCalledCount = 0
  /// The data passed to the last call of `writeValue(_:for:type:)`.
  public var writeValueData: Data?
  /// The characteristic passed to the last call of `writeValue(_:for:type:)`.
  public var writeValueCharacteristic: CBCharacteristic?
  /// The write type passed to the last call of `writeValue(_:for:type:)`.
  public var writeValueType: CBCharacteristicWriteType?

  /// Mocks writing a characteristic value.
  public func writeValue(
    _ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType
  ) {
    writeValueWasCalledCount += 1
    writeValueData = data
    writeValueCharacteristic = characteristic
    writeValueType = type
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

  /// Count of how many times `discoverDescriptors(for:)` was called.
  public var discoverDescriptorsWasCalledCount = 0
  /// The characteristic passed to the last call of `discoverDescriptors(for:)`.
  public var discoverDescriptorsCharacteristic: CBCharacteristic?

  /// Mocks discovering descriptors for a characteristic.
  public func discoverDescriptors(for characteristic: CBCharacteristic) {
    discoverDescriptorsWasCalledCount += 1
    discoverDescriptorsCharacteristic = characteristic
  }

  /// Count of how many times `readValue(for:)` (descriptor) was called.
  public var readValueForDescriptorWasCalledCount = 0
  /// The descriptor passed to the last call of `readValue(for:)`.
  public var readValueForDescriptorDescriptor: CBDescriptor?

  /// Mocks reading a descriptor value.
  public func readValue(for descriptor: CBDescriptor) {
    readValueForDescriptorWasCalledCount += 1
    readValueForDescriptorDescriptor = descriptor
  }

  /// Count of how many times `writeValue(_:for:)` (descriptor) was called.
  public var writeValueForDescriptorWasCalledCount = 0
  /// The data passed to the last call of `writeValue(_:for:)`.
  public var writeValueForDescriptorData: Data?
  /// The descriptor passed to the last call of `writeValue(_:for:)`.
  public var writeValueForDescriptorDescriptor: CBDescriptor?

  /// Mocks writing a descriptor value.
  public func writeValue(_ data: Data, for descriptor: CBDescriptor) {
    writeValueForDescriptorWasCalledCount += 1
    writeValueForDescriptorData = data
    writeValueForDescriptorDescriptor = descriptor
  }

  /// Count of how many times `openL2CAPChannel(_:)` was called.
  public var openL2CAPChannelWasCalledCount = 0
  /// The PSM passed to the last call of `openL2CAPChannel(_:)`.
  public var openL2CAPChannelPSM: CBL2CAPPSM?

  /// Mocks opening an L2CAP channel.
  public func openL2CAPChannel(_ PSM: CBL2CAPPSM) {
    openL2CAPChannelWasCalledCount += 1
    openL2CAPChannelPSM = PSM
  }
}
