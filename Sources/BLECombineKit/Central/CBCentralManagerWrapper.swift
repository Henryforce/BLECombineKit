//
//  CBManagerWrapper.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import CoreBluetooth
import Foundation

/// Interface for wrapping the CBCentralManager.
/// This interface is critical in order to mock the CBCentralManager calls as Apple has the
/// init restricted.
public protocol CBCentralManagerWrapper {
  var manager: CBCentralManager? { get }
  var isScanning: Bool { get }

  func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper]
  func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralWrapper]
  func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?)
  func stopScan()
  func connect(_ wrappedPeripheral: CBPeripheralWrapper, options: [String: Any]?)
  func cancelPeripheralConnection(_ wrappedPeripheral: CBPeripheralWrapper)
  #if !os(macOS)
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?)
  #endif
}

final class StandardCBCentralManagerWrapper: CBCentralManagerWrapper {

  var manager: CBCentralManager? {
    wrappedManager
  }

  var isScanning: Bool {
    wrappedManager.isScanning
  }

  let wrappedManager: CBCentralManager

  init(with manager: CBCentralManager) {
    self.wrappedManager = manager
  }

  func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper] {
    wrappedManager
      .retrievePeripherals(withIdentifiers: identifiers)
  }

  func retrieveConnectedPeripherals(
    withServices serviceUUIDs: [CBUUID]
  ) -> [CBPeripheralWrapper] {
    wrappedManager
      .retrieveConnectedPeripherals(withServices: serviceUUIDs)
  }

  func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?) {
    wrappedManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
  }

  func stopScan() {
    wrappedManager.stopScan()
  }

  func connect(_ wrappedPeripheral: CBPeripheralWrapper, options: [String: Any]?) {
    guard let manager else { return }
    wrappedPeripheral.connect(manager: manager)
  }

  func cancelPeripheralConnection(_ wrappedPeripheral: CBPeripheralWrapper) {
    guard let manager else { return }
    wrappedPeripheral.cancelConnection(manager: manager)
  }

  #if !os(macOS)
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?) {

      wrappedManager.registerForConnectionEvents(options: options)

    }
  #endif

  func setupDelegate(_ delegate: CBCentralManagerDelegate) {
    wrappedManager.delegate = delegate
  }

}
