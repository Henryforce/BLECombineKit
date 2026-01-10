//
//  MockCBPeripheralWrapper.swift
//  BLECombineKitMocks
//
//  Created by Henry Javier Serrano Echeverria on 10/1/26.
//

import CoreBluetooth
import Foundation
import BLECombineKit

open class MockCBPeripheralWrapper: CBPeripheralWrapper, @unchecked Sendable {

    public init() { }

    public var wrappedPeripheral: CBPeripheral?

    public var stateValue: CBPeripheralState = .disconnected
    public var state: CBPeripheralState {
        stateValue
    }

    public var identifierValue: UUID = UUID()
    public var identifier: UUID {
        identifierValue
    }

    public var nameValue: String?
    public var name: String? {
        nameValue
    }

    public var servicesValue: [CBService]?
    public var services: [CBService]? {
        servicesValue
    }

    public var setupDelegateWasCalledCount = 0
    public var setupDelegateDelegate: CBPeripheralDelegate?
    public func setupDelegate(_ delegate: CBPeripheralDelegate) {
        setupDelegateWasCalledCount += 1
        setupDelegateDelegate = delegate
    }

    public var connectWasCalledCount = 0
    public var connectManager: CBCentralManager?
    public func connect(manager: CBCentralManager) {
        connectWasCalledCount += 1
        connectManager = manager
    }

    public var cancelConnectionWasCalledCount = 0
    public var cancelConnectionManager: CBCentralManager?
    public func cancelConnection(manager: CBCentralManager) {
        cancelConnectionWasCalledCount += 1
        cancelConnectionManager = manager
    }

    public var readRSSIWasCalledCount = 0
    public func readRSSI() {
        readRSSIWasCalledCount += 1
    }

    public var discoverServicesWasCalledCount = 0
    public var discoverServicesUUIDs: [CBUUID]?
    public func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        discoverServicesWasCalledCount += 1
        discoverServicesUUIDs = serviceUUIDs
    }

    public var discoverIncludedServicesWasCalledCount = 0
    public var discoverIncludedServicesUUIDs: [CBUUID]?
    public var discoverIncludedServicesService: CBService?
    public func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) {
        discoverIncludedServicesWasCalledCount += 1
        discoverIncludedServicesUUIDs = includedServiceUUIDs
        discoverIncludedServicesService = service
    }

    public var discoverCharacteristicsWasCalledCount = 0
    public var discoverCharacteristicsUUIDs: [CBUUID]?
    public var discoverCharacteristicsService: CBService?
    public func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        discoverCharacteristicsWasCalledCount += 1
        discoverCharacteristicsUUIDs = characteristicUUIDs
        discoverCharacteristicsService = service
    }

    public var readValueWasCalledCount = 0
    public var readValueCharacteristic: CBCharacteristic?
    public func readValue(for characteristic: CBCharacteristic) {
        readValueWasCalledCount += 1
        readValueCharacteristic = characteristic
    }

    public var maximumWriteValueLengthReturnValue: Int = 0
    public var maximumWriteValueLengthWasCalledCount = 0
    public var maximumWriteValueLengthType: CBCharacteristicWriteType?
    public func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
        maximumWriteValueLengthWasCalledCount += 1
        maximumWriteValueLengthType = type
        return maximumWriteValueLengthReturnValue
    }

    public var writeValueWasCalledCount = 0
    public var writeValueData: Data?
    public var writeValueCharacteristic: CBCharacteristic?
    public var writeValueType: CBCharacteristicWriteType?
    public func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        writeValueWasCalledCount += 1
        writeValueData = data
        writeValueCharacteristic = characteristic
        writeValueType = type
    }

    public var setNotifyValueWasCalledCount = 0
    public var setNotifyValueEnabled: Bool?
    public var setNotifyValueCharacteristic: CBCharacteristic?
    public func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        setNotifyValueWasCalledCount += 1
        setNotifyValueEnabled = enabled
        setNotifyValueCharacteristic = characteristic
    }

    public var discoverDescriptorsWasCalledCount = 0
    public var discoverDescriptorsCharacteristic: CBCharacteristic?
    public func discoverDescriptors(for characteristic: CBCharacteristic) {
        discoverDescriptorsWasCalledCount += 1
        discoverDescriptorsCharacteristic = characteristic
    }

    public var readValueForDescriptorWasCalledCount = 0
    public var readValueForDescriptorDescriptor: CBDescriptor?
    public func readValue(for descriptor: CBDescriptor) {
        readValueForDescriptorWasCalledCount += 1
        readValueForDescriptorDescriptor = descriptor
    }

    public var writeValueForDescriptorWasCalledCount = 0
    public var writeValueForDescriptorData: Data?
    public var writeValueForDescriptorDescriptor: CBDescriptor?
    public func writeValue(_ data: Data, for descriptor: CBDescriptor) {
        writeValueForDescriptorWasCalledCount += 1
        writeValueForDescriptorData = data
        writeValueForDescriptorDescriptor = descriptor
    }

    public var openL2CAPChannelWasCalledCount = 0
    public var openL2CAPChannelPSM: CBL2CAPPSM?
    public func openL2CAPChannel(_ PSM: CBL2CAPPSM) {
        openL2CAPChannelWasCalledCount += 1
        openL2CAPChannelPSM = PSM
    }
}
