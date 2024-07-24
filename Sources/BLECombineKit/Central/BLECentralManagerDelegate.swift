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

  let didConnectPeripheral = PassthroughSubject<CBPeripheralWrapper, Never>()
  let didDisconnectPeripheral = PassthroughSubject<CBPeripheralWrapper, Never>()
  let didFailToConnect = PassthroughSubject<CBPeripheralWrapper, Never>()
  let didDiscoverAdvertisementData = PassthroughSubject<
    DidDiscoverAdvertisementDataResult, BLEError
  >()
  let didUpdateState = PassthroughSubject<ManagerState, Never>()
  let willRestoreState = PassthroughSubject<[String: Any], Never>()
  let didUpdateANCSAuthorization = PassthroughSubject<CBPeripheralWrapper, Never>()

  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    //    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didConnectPeripheral.send(peripheral)
  }

  public func centralManager(
    _ central: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral,
    error: Error?
  ) {
    //    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didDisconnectPeripheral.send(peripheral)
  }

  public func centralManager(
    _ central: CBCentralManager,
    didFailToConnect peripheral: CBPeripheral,
    error: Error?
  ) {
    //    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    didFailToConnect.send(peripheral)
  }

  public func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any],
    rssi RSSI: NSNumber
  ) {
    //    let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
    let result = (peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
    didDiscoverAdvertisementData.send(result)
  }

  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    guard let state = ManagerState(rawValue: central.state.rawValue) else { return }
    didUpdateState.send(state)
  }

  public func centralManager(
    _ central: CBCentralManager,
    willRestoreState dict: [String: Any]
  ) {
    willRestoreState.send(dict)
  }

  #if !os(macOS)
    public func centralManager(
      _ central: CBCentralManager,
      didUpdateANCSAuthorizationFor peripheral: CBPeripheral
    ) {
      //      let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
      didUpdateANCSAuthorization.send(peripheral)
    }
  #endif

}
