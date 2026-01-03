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
/// This interface is critical in order to mock the CBCentralManager calls.
public protocol CBCentralManagerWrapper: Sendable {
  /// The CBCentralManager this interface wraps to.
  /// Note that CBCentralManager conforms to CBCentralManagerWrapper and this getter interface is a convenient way to avoid an expensive downcast. That is, if you need a fixed reference to the CBCentralManager object do not run `let validManager = manager as? CBCentralManager`, simply run `let validManager = manager.wrappedManager` which will run significantly faster.
  var wrappedManager: CBCentralManager? { get }

  /// The delegate object that will receive central events.
  var delegate: CBCentralManagerDelegate? { get }

  /// The scanning status of this manager.
  var isScanning: Bool { get }

  /// Set up the delegate of the wrapped CBCentralManager.
  /// Avoid calling this method unless you explicitly want to listen to delegate events at the cost of breaking the manager's observable events.
  func setupDelegate(_ delegate: CBCentralManagerDelegate)

  /// Retrieve peripherals.
  func retrieveCBPeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper]

  /// Retrieve all the connected peripherals.
  func retrieveConnectedCBPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralWrapper]

  /// Start scanning for peripherals with the given set of services and options.
  func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?)

  /// Stop scanning for peripherals.
  func stopScan()

  /// Connect to a wrapped peripheral with options.
  func connect(_ wrappedPeripheral: CBPeripheralWrapper, options: [String: Any]?)

  /// Cancel the connection to a wrapped peripheral.
  func cancelPeripheralConnection(_ wrappedPeripheral: CBPeripheralWrapper)

  #if os(iOS) || os(tvOS) || os(watchOS)
    /// Register for connection events with options.
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?)
  #endif
}

extension CBCentralManager: CBCentralManagerWrapper {
  public var wrappedManager: CBCentralManager? {
    self
  }

  public func setupDelegate(_ delegate: CBCentralManagerDelegate) {
    self.delegate = delegate
  }

  public func retrieveCBPeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralWrapper] {
    return retrievePeripherals(withIdentifiers: identifiers)
  }

  public func retrieveConnectedCBPeripherals(withServices serviceUUIDs: [CBUUID])
    -> [CBPeripheralWrapper]
  {
    return retrieveConnectedPeripherals(withServices: serviceUUIDs)
  }

  public func connect(_ wrappedPeripheral: CBPeripheralWrapper, options: [String: Any]?) {
    wrappedPeripheral.connect(manager: self)
  }

  public func cancelPeripheralConnection(_ wrappedPeripheral: CBPeripheralWrapper) {
    wrappedPeripheral.cancelConnection(manager: self)
  }

}
