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

typealias DidDiscoverServicesResult = (peripheral: CBPeripheralWrapper, error: Error?)
typealias DidDiscoverCharacteristicsResult = (peripheral: CBPeripheralWrapper, service: CBService, error: Error?)
typealias DidUpdateValueForCharacteristicResult = (peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: Error?)
typealias DidDiscoverDescriptorForCharacteristicResult = (peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: Error?)
typealias DidUpdateValueForDescriptorResult = (peripheral: CBPeripheralWrapper, descriptor: CBDescriptor, error: Error?)
typealias DidReadRSSIResult = (peripheral: CBPeripheralWrapper, rssi: NSNumber, error: Error?)
typealias DidWriteValueForCharacteristicResult = (peripheral: CBPeripheralWrapper, characteristic: CBCharacteristic, error: Error?)

final class BLEPeripheralDelegate: NSObject {
    
    // Discovering Services
    let didDiscoverServices = PassthroughSubject<DidDiscoverServicesResult, Error>()
    
    // Discovering Characteristics and their Descriptors
    let didDiscoverCharacteristics = PassthroughSubject<DidDiscoverCharacteristicsResult, Error>()
    let didDiscoverDescriptors = PassthroughSubject<DidDiscoverDescriptorForCharacteristicResult, Error>()
  
    // Retrieving Characteristic and Descriptor Values
    let didUpdateValueForCharacteristic = PassthroughSubject<DidUpdateValueForCharacteristicResult, Error>()
    let didUpdateValueForDescriptor = PassthroughSubject<DidUpdateValueForDescriptorResult, Error>()
    
    // Retrieving a Peripheral’s RSSI Data
    let didReadRSSI = PassthroughSubject<DidReadRSSIResult, Error>()
    
    // Writing Characteristic and Descriptor Values
    let didWriteValueForCharacteristic = PassthroughSubject<DidWriteValueForCharacteristicResult, Error>()
    
}

extension BLEPeripheralDelegate: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didDiscoverServices.send((peripheral: peripheralWrapper, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didDiscoverCharacteristics.send((peripheral: peripheralWrapper, service: service, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didDiscoverDescriptors.send((peripheral: peripheralWrapper, characteristic: characteristic, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didUpdateValueForCharacteristic.send((peripheral: peripheralWrapper, characteristic: characteristic, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didUpdateValueForDescriptor.send((peripheral: peripheralWrapper, descriptor: descriptor, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didReadRSSI.send((peripheral: peripheralWrapper, rssi: RSSI, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didWriteValueForCharacteristic.send((peripheral: peripheralWrapper, characteristic: characteristic, error: error))
    }
}
