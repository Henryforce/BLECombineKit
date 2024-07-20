//
//  BLEPeripheralMocks.swift
//  BLECombineKitTests
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

@testable import BLECombineKit

struct SetNotifyValueWasCalledStackValue: Equatable {
  let enabled: Bool
  let characteristic: CBCharacteristic
}

final class MockBLEPeripheral: BLEPeripheral, BLETrackedPeripheral {
  let connectionState = CurrentValueSubject<Bool, Never>(false)
  var associatedPeripheral: CBPeripheralWrapper

  init() {
    self.associatedPeripheral = MockCBPeripheralWrapper()
  }

  public func observeConnectionState() -> AnyPublisher<Bool, Never> {
    return Just.init(true).eraseToAnyPublisher()
  }

  var connectWasCalled = false
  func connect(with options: [String: Any]?) -> AnyPublisher<BLEPeripheral, BLEError> {
    connectWasCalled = true
    let blePeripheral = StandardBLEPeripheral(peripheral: associatedPeripheral, centralManager: nil)
    return Just(blePeripheral)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  var disconnectWasCalled = false
  func disconnect() -> AnyPublisher<Never, BLEError> {
    disconnectWasCalled = true
    return Empty(completeImmediately: true).eraseToAnyPublisher()
  }

  var discoverServiceWasCalled = false
  func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, BLEError> {
    discoverServiceWasCalled = true
    let cbService = CBMutableService(type: CBUUID(string: "0x0000"), primary: true)
    let service = BLEService(value: cbService, peripheral: self)
    return Just.init(service)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  var discoverCharacteristicsWasCalled = false
  func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService)
    -> AnyPublisher<BLECharacteristic, BLEError>
  {
    discoverCharacteristicsWasCalled = true
    let cbCharacteristic = CBMutableCharacteristic(
      type: CBUUID(string: "0x0000"),
      properties: CBCharacteristicProperties(),
      value: Data(),
      permissions: CBAttributePermissions()
    )
    let characteristic = BLECharacteristic(value: cbCharacteristic, peripheral: self)
    return Just(characteristic)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  var observeValueWasCalled = false
  func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
    observeValueWasCalled = true
    let data = BLEData(value: Data(), peripheral: self)
    return Just(data)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  var readValueWasCalledStack = [CBCharacteristic]()
  func readValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, BLEError> {
    readValueWasCalledStack.append(characteristic)
    let data = BLEData(value: Data(), peripheral: self)
    return Just(data)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  var observeValueUpdateAndSetNotificationWasCalled = false
  func observeValueUpdateAndSetNotification(for characteristicUUID: CBCharacteristic)
    -> AnyPublisher<BLEData, BLEError>
  {
    observeValueUpdateAndSetNotificationWasCalled = true
    let data = BLEData(value: Data(), peripheral: self)
    return Just(data)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  var setNotifyValueWasCalledStack = [SetNotifyValueWasCalledStackValue]()
  func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
    setNotifyValueWasCalledStack.append(
      SetNotifyValueWasCalledStackValue(enabled: enabled, characteristic: characteristic)
    )
  }

  var observeNameValueWasCalled = false
  func observeNameValue() -> AnyPublisher<String, Never> {
    observeNameValueWasCalled = true
    return Just.init("Test")
      .eraseToAnyPublisher()
  }

  var observeRSSIValueWasCalled = false
  func observeRSSIValue() -> AnyPublisher<NSNumber, BLEError> {
    observeRSSIValueWasCalled = true
    return Just.init(NSNumber(value: 0))
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  var writeValueWasCalled = false
  func writeValue(
    _ data: Data,
    for characteristic: CBCharacteristic,
    type: CBCharacteristicWriteType
  ) -> AnyPublisher<Never, BLEError> {
    writeValueWasCalled = true
    return Empty(completeImmediately: true).setFailureType(to: BLEError.self).eraseToAnyPublisher()
  }

}

final class MockCBPeripheralWrapper: CBPeripheralWrapper {

  var mockPeripheral: CBPeripheral!
  var peripheral: CBPeripheral { mockPeripheral }

  var state = CBPeripheralState.connected

  var identifier = UUID()

  var name: String? = "MockedPeripheral"

  var mockedServices: [CBService]?
  var services: [CBService]? {
    return mockedServices
  }

  var setupDelegateWasCalledStack = [CBPeripheralDelegate]()
  func setupDelegate(_ delegate: CBPeripheralDelegate) {
    setupDelegateWasCalledStack.append(delegate)
  }

  var readRSSIWasCalled = false
  func readRSSI() {
    readRSSIWasCalled = true
  }

  var discoverServicesWasCalled = false
  func discoverServices(_ serviceUUIDs: [CBUUID]?) {
    discoverServicesWasCalled = true
  }

  func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) {

  }

  var discoverCharacteristicsWasCalled = false
  func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
    discoverCharacteristicsWasCalled = true
  }

  var readValueForCharacteristicWasCalledStack = [CBCharacteristic]()
  func readValue(for characteristic: CBCharacteristic) {
    readValueForCharacteristicWasCalledStack.append(characteristic)
  }

  func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
    return 0
  }

  var writeValueForCharacteristicWasCalled = false
  func writeValue(
    _ data: Data,
    for characteristic: CBCharacteristic,
    type: CBCharacteristicWriteType
  ) {
    writeValueForCharacteristicWasCalled = true
  }

  var setNotifyValueWasCalledStack = [SetNotifyValueWasCalledStackValue]()
  func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
    setNotifyValueWasCalledStack.append(
      SetNotifyValueWasCalledStackValue(enabled: enabled, characteristic: characteristic)
    )
  }

  func discoverDescriptors(for characteristic: CBCharacteristic) {

  }

  var readValueForDescriptorWasCalled = false
  func readValue(for descriptor: CBDescriptor) {
    readValueForDescriptorWasCalled = true
  }

  var writeValueForDescriptorWasCalled = false
  func writeValue(_ data: Data, for descriptor: CBDescriptor) {
    writeValueForDescriptorWasCalled = true
  }

  func openL2CAPChannel(_ PSM: CBL2CAPPSM) {

  }
}
