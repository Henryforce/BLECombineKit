//
//  MockCBPeripheralWrapper.swift
//  BLECombineKitMocks
//
//  Created by Henry Javier Serrano Echeverria on 10/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import CoreBluetooth

public final class MockCBPeripheralWrapper: CBPeripheralWrapper {
    
    public var peripheral: CBPeripheral?
    
    public var state = CBPeripheralState.connected
    
    public var identifier = UUID.init()
    
    public var name: String? = "MockedPeripheral"
    
    public init() { }
    
    public var mockedServices: [CBService]?
    public var services: [CBService]? {
        return mockedServices
    }
    
    public var readRSSIWasCalledCount = 0
    public func readRSSI() {
        readRSSIWasCalledCount += 1
    }
    
    public var discoverServicesWasCalledCount = 0
    public func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        discoverServicesWasCalledCount += 1
    }
    
    public var discoverIncludedServicesWasCalledCount = 0
    public func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) {
        discoverIncludedServicesWasCalledCount += 1
    }
    
    public var discoverCharacteristicsWasCalledCount = 0
    public func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        discoverCharacteristicsWasCalledCount += 1
    }
    
    public var readValueForCharacteristicWasCalledCount = 0
    public func readValue(for characteristic: CBCharacteristic) {
        readValueForCharacteristicWasCalledCount += 1
    }
    
    public var maximumWriteValueLengthWasCalledCount = 0
    public var maximumWriteValueLengthValue: Int = .zero
    public func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
        maximumWriteValueLengthWasCalledCount += 1
        return maximumWriteValueLengthValue
    }
    
    public var writeValueForCharacteristicWasCalledCount = 0
    public func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        writeValueForCharacteristicWasCalledCount += 1
    }
    
    public var setNotifyValueWasCalledCount = 0
    public func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        setNotifyValueWasCalledCount += 1
    }
    
    public var discoverDescriptorsWasCalledCount = 0
    public func discoverDescriptors(for characteristic: CBCharacteristic) {
        discoverDescriptorsWasCalledCount += 1
    }
    
    public var readValueForDescriptorWasCalledCount = 0
    public func readValue(for descriptor: CBDescriptor) {
        readValueForDescriptorWasCalledCount += 1
    }
    
    public var writeValueForDescriptorWasCalledCount = 0
    public func writeValue(_ data: Data, for descriptor: CBDescriptor) {
        writeValueForDescriptorWasCalledCount += 1
    }
    
    public var openL2CAPChannelWasCalledCount = 0
    public func openL2CAPChannel(_ PSM: CBL2CAPPSM) {
        openL2CAPChannelWasCalledCount += 1
    }
}
