//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

typealias DidDiscoverAdvertisementDataResult = (
  peripheral: CBPeripheralWrapper, advertisementData: [String: Any], rssi: NSNumber
)

final class BLECentralManagerDelegate: NSObject, CBCentralManagerDelegate {

  let didConnectPeripheral = PassthroughSubject<CBPeripheralWrapper, BLEError>()
  let didDisconnectPeripheral = PassthroughSubject<CBPeripheralWrapper, Never>()
  let didFailToConnect = PassthroughSubject<CBPeripheralWrapper, Never>()
  let didDiscoverAdvertisementData = PassthroughSubject<
    DidDiscoverAdvertisementDataResult, BLEError
  >()
  let didUpdateState = PassthroughSubject<CBManagerState, Never>()
  let willRestoreState = PassthroughSubject<[String: Any], Never>()
  let didUpdateANCSAuthorization = PassthroughSubject<CBPeripheralWrapper, Never>()

  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    didConnectPeripheral.send(peripheral)
  }

  public func centralManager(
    _ central: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral,
    error: Error?
  ) {
    didDisconnectPeripheral.send(peripheral)
  }

  public func centralManager(
    _ central: CBCentralManager,
    didFailToConnect peripheral: CBPeripheral,
    error: Error?
  ) {
    didFailToConnect.send(peripheral)
  }

  public func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any],
    rssi RSSI: NSNumber
  ) {
    let result = (peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
    didDiscoverAdvertisementData.send(result)
  }

  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    didUpdateState.send(central.state)
  }

  public func centralManager(
    _ central: CBCentralManager,
    willRestoreState dict: [String: Any]
  ) {
    willRestoreState.send(dict)
  }

  #if os(iOS) || os(tvOS) || os(watchOS)
    public func centralManager(
      _ central: CBCentralManager,
      didUpdateANCSAuthorizationFor peripheral: CBPeripheral
    ) {
      didUpdateANCSAuthorization.send(peripheral)
    }
  #endif

}
