//
//  BLEPeripheralManagerDelegateWrapper.swift
//  BLECombineKit
//
//  Created by Przemyslaw Stasiak on 12/07/2021.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

/// Based on Polidea/RxBluetoothKit/Source/CBPeripheralManagerDelegateWrapper.swift
///
/// See original source on [GitHub](https://github.com/Polidea/RxBluetoothKit/blob/2a95bce60fb569df57d7bec41d215fe58f56e1d4/Source/CBPeripheralManagerDelegateWrapper.swift).
///
final class BLEPeripheralManagerDelegate: NSObject, CBPeripheralManagerDelegate {

  let didUpdateState = PassthroughSubject<CBManagerState, Never>()
  let isReady = PassthroughSubject<Void, Never>()
  let didStartAdvertising = PassthroughSubject<Error?, Never>()
  let didReceiveRead = PassthroughSubject<CBATTRequest, Never>()
  let willRestoreState = CurrentValueSubject<[String: Any], Never>([:])
  let didAddService = PassthroughSubject<(CBService, Error?), Never>()
  let didReceiveWrite = PassthroughSubject<[CBATTRequest], Never>()
  let didSubscribeTo = PassthroughSubject<(CBCentral, CBCharacteristic), Never>()
  let didUnsubscribeFrom = PassthroughSubject<(CBCentral, CBCharacteristic), Never>()
  let didPublishL2CAPChannel = PassthroughSubject<(CBL2CAPPSM, Error?), Never>()
  let didUnpublishL2CAPChannel = PassthroughSubject<(CBL2CAPPSM, Error?), Never>()
  private var _didOpenChannel: Any?
  var didOpenChannel: PassthroughSubject<(CBL2CAPChannel?, Error?), Never> {
    if _didOpenChannel == nil {
      _didOpenChannel = PassthroughSubject<(CBL2CAPChannel?, Error?), Never>()
    }
    return _didOpenChannel as! PassthroughSubject<(CBL2CAPChannel?, Error?), Never>
  }

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    didUpdateState.send(peripheral.state)
  }

  func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    isReady.send()
  }

  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    didStartAdvertising.send(error)
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    didReceiveRead.send(request)
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String: Any]) {
    willRestoreState.send(dict)
  }

  func peripheralManager(
    _ peripheral: CBPeripheralManager,
    didAdd service: CBService,
    error: Error?
  ) {
    didAddService.send((service, error))
  }

  func peripheralManager(
    _ peripheral: CBPeripheralManager,
    didReceiveWrite requests: [CBATTRequest]
  ) {
    didReceiveWrite.send(requests)
  }

  func peripheralManager(
    _ peripheral: CBPeripheralManager,
    central: CBCentral,
    didSubscribeTo characteristic: CBCharacteristic
  ) {
    didSubscribeTo.send((central, characteristic))
  }

  func peripheralManager(
    _ peripheral: CBPeripheralManager,
    central: CBCentral,
    didUnsubscribeFrom characteristic: CBCharacteristic
  ) {
    didUnsubscribeFrom.send((central, characteristic))
  }

  func peripheralManager(
    _ peripheral: CBPeripheralManager,
    didPublishL2CAPChannel PSM: CBL2CAPPSM,
    error: Error?
  ) {
    didPublishL2CAPChannel.send((PSM, error))
  }

  func peripheralManager(
    _ peripheral: CBPeripheralManager,
    didUnpublishL2CAPChannel PSM: CBL2CAPPSM,
    error: Error?
  ) {
    didUnpublishL2CAPChannel.send((PSM, error))
  }

  func peripheralManager(
    _ peripheral: CBPeripheralManager,
    didOpen channel: CBL2CAPChannel?,
    error: Error?
  ) {
    didOpenChannel.send((channel, error))
  }
}
