//
//  BLEPeripheralDelegate.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

typealias DidDiscoverCharacteristicsResult = (peripheral: CBPeripheralWrapper, service: CBService)
typealias DidUpdateValueForCharacteristicResult = (peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic)
typealias DidUpdateValueForDescriptorResult = (peripheral: CBPeripheralWrapper, descriptor: CBDescriptor)
typealias DidReadRSSIResult = (peripheral: CBPeripheralWrapper, rssi: NSNumber)

final class BLEPeripheralDelegate: NSObject {
    
    // Discovering Services
    let didDiscoverServices = PassthroughSubject<CBPeripheralWrapper, Error>()
    
    // Discovering Characteristics and their Descriptors
    let didDiscoverCharacteristics = PassthroughSubject<DidDiscoverCharacteristicsResult, Error>()
    let didDiscoverDescriptors = PassthroughSubject<(CBPeripheralWrapper, for: CBCharacteristic), Error>()
  
    // Retrieving Characteristic and Descriptor Values
    let didUpdateValueForCharacteristic = PassthroughSubject<DidUpdateValueForCharacteristicResult, Error>()
    let didUpdateValueForDescriptor = PassthroughSubject<DidUpdateValueForDescriptorResult, Error>()
    
    // Retrieving a Peripheral’s RSSI Data
    let didReadRSSI = PassthroughSubject<DidReadRSSIResult, Error>()
    
}

extension BLEPeripheralDelegate: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let peripheralWrapper = CBPeripheralWrapperImpl(peripheral: peripheral)
        didDiscoverServices.send(peripheralWrapper)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let peripheralWrapper = CBPeripheralWrapperImpl(peripheral: peripheral)
        didDiscoverCharacteristics.send((peripheral: peripheralWrapper, service: service))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        let peripheralWrapper = CBPeripheralWrapperImpl(peripheral: peripheral)
        didDiscoverDescriptors.send((peripheralWrapper, for: characteristic))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let peripheralWrapper = CBPeripheralWrapperImpl(peripheral: peripheral)
        didUpdateValueForCharacteristic.send((peripheral: peripheralWrapper, characteristic: characteristic))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        let peripheralWrapper = CBPeripheralWrapperImpl(peripheral: peripheral)
        didUpdateValueForDescriptor.send((peripheral: peripheralWrapper, descriptor: descriptor))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        let peripheralWrapper = CBPeripheralWrapperImpl(peripheral: peripheral)
        didReadRSSI.send((peripheral: peripheralWrapper, rssi: RSSI))
    }
}
