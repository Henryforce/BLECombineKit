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

public protocol BLEPeripheral {
    var peripheral: CBPeripheralWrapper { get }

    func observeConnectionState() -> AnyPublisher<Bool, Never>
    func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError>
    @discardableResult func disconnect() -> AnyPublisher<Never, BLEError>
    func observeNameValue() -> AnyPublisher<String, Never>
    func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError>
    func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError>
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, BLEError>
    func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>
    func observeValueUpdateAndSetNotification(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError>
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic)
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) -> AnyPublisher<Never, BLEError>
}

protocol BLEPeripheralState {
    var connectionState: CurrentValueSubject<Bool, Never> { get }
}
