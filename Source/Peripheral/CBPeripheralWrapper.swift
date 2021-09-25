//
//  CBPeripheralWrapper.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol CBPeripheralWrapper {
    var peripheral: CBPeripheral { get }
    var state: CBPeripheralState { get }
    var identifier: UUID { get }
    var name: String? { get }
    var services: [CBService]? { get }
    
    func readRSSI()
    func discoverServices(_ serviceUUIDs: [CBUUID]?)
    func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService)
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService)
    func readValue(for characteristic: CBCharacteristic)
    func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType)
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic)
    func discoverDescriptors(for characteristic: CBCharacteristic)
    func readValue(for descriptor: CBDescriptor)
    func writeValue(_ data: Data, for descriptor: CBDescriptor)
    func openL2CAPChannel(_ PSM: CBL2CAPPSM)
}

final class StandardCBPeripheralWrapper: CBPeripheralWrapper {
    
    var peripheral: CBPeripheral {
        self.wrappedPeripheral
    }
    
    var state: CBPeripheralState {
        self.wrappedPeripheral.state
    }
    
    var identifier: UUID {
        self.wrappedPeripheral.identifier
    }
    
    var name: String? {
        self.wrappedPeripheral.name
    }
    
    var services: [CBService]? {
        self.wrappedPeripheral.services
    }
    
    let wrappedPeripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.wrappedPeripheral = peripheral
    }
    
    func setupDelegate(_ delegate: CBPeripheralDelegate) {
        wrappedPeripheral.delegate = delegate
    }
    
    func readRSSI() {
        self.wrappedPeripheral.readRSSI()
    }
    
    func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        self.wrappedPeripheral.discoverServices(serviceUUIDs)
    }
    
    func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) {
        self.wrappedPeripheral.discoverIncludedServices(includedServiceUUIDs, for: service)
    }
    
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        self.wrappedPeripheral.discoverCharacteristics(characteristicUUIDs, for: service)
    }
    
    func readValue(for characteristic: CBCharacteristic) {
        self.wrappedPeripheral.readValue(for: characteristic)
    }
    
    func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
        self.wrappedPeripheral.maximumWriteValueLength(for: type)
    }
    
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        self.wrappedPeripheral.writeValue(data, for: characteristic, type: type)
    }
    
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        wrappedPeripheral.setNotifyValue(enabled, for: characteristic)
    }
    
    func discoverDescriptors(for characteristic: CBCharacteristic) {
        wrappedPeripheral.discoverDescriptors(for: characteristic)
    }
    
    func readValue(for descriptor: CBDescriptor) {
        wrappedPeripheral.readValue(for: descriptor)
    }
    
    func writeValue(_ data: Data, for descriptor: CBDescriptor) {
        wrappedPeripheral.writeValue(data, for: descriptor)
    }
    
    func openL2CAPChannel(_ PSM: CBL2CAPPSM) {
        wrappedPeripheral.openL2CAPChannel(PSM)
    }
    
}
