//
//  BLECentralManager.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 30/4/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
import CoreBluetooth
import Foundation

/// Interface definining the Bluetooth Central Manager that provides Combine APIs.
public protocol BLECentralManager: AnyObject {
  /// Reference to the actual Bluetooth Manager, which is conveniently wrapped.
  var associatedCentralManager: CBCentralManagerWrapper { get }

  /// The latest scanning status.
  var isScanning: Bool { get }

  /// The current state as a publisher.
  var state: AnyPublisher<ManagerState, Never> { get }

  /// Retrieve peripherals given a set of identifiers.
  /// This method will generate events for any matching peripheral or an error.
  func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<
    BLEPeripheral, BLEError
  >

  /// Retrieve connected peripherals given a set of service identifiers.
  /// This method will generate events for any matching peripheral or an error.
  func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> AnyPublisher<
    BLEPeripheral, BLEError
  >

  /// Start scanning for peripherals given a set of service identifiers and options.
  /// This method will generate scan result events or an error.
  func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?)
    -> AnyPublisher<BLEScanResult, BLEError>

  /// Stop scanning.
  func stopScan()

  /// Connect to a peripheral with some options.
  func connect(peripheral: BLEPeripheral, options: [String: Any]?) -> AnyPublisher<
    BLEPeripheral, BLEError
  >

  /// Cancel a peripheral connection.
  func cancelPeripheralConnection(_ peripheral: BLEPeripheral) -> AnyPublisher<Never, Never>

  /// Register for any connection events.
  #if os(iOS) || os(tvOS) || os(watchOS)
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?)
  #endif

  /// Observe for any changes to the willRestoreState.
  /// This method will generate an event for each update to willRestoreState, if any.
  func observeWillRestoreState() -> AnyPublisher<[String: Any], Never>

  /// Observe any update to the ANCS authorization.
  /// This method will trigger an event for any call to the delegate method
  /// `didUpdateANCSAuthorizationFor`.
  func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never>
}
