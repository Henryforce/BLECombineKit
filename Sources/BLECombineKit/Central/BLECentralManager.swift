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
public protocol BLECentralManager: AnyObject, Sendable {
  /// Reference to the actual Bluetooth Manager, which is conveniently wrapped.
  var associatedCentralManager: CBCentralManagerWrapper { get }

  /// The latest scanning status.
  var isScanning: Bool { get }

  /// The current state as a publisher.
  var state: AnyPublisher<CBManagerState, Never> { get }

  /// Retrieve a list of known peripherals by their identifiers.
  ///
  /// The returned Publisher can complete without emitting any peripherals if there are no known peripherals. Depending on the usage, `collect(_:)` might be an option for converting the output into an array.
  ///
  /// - Returns: A Publisher that will emit peripherals and then complete.
  func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> AnyPublisher<
    BLEPeripheral, BLEError
  >

  /// Returns a list of the peripherals connected to the system whose services match a given set of criteria.
  ///
  /// The returned Publisher can complete without emitting any peripherals if there are no connected peripherals. Depending on the usage, `collect(_:)` might be an option for converting the output into an array.
  ///
  /// - Returns: A Publisher that will emit peripherals and then complete.
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
  ///
  /// - Returns: A Publisher that emits a completion when the given peripheral is disconnected.
  func cancelPeripheralConnection(_ peripheral: BLEPeripheral) -> AnyPublisher<Never, Never>

  #if os(iOS) || os(tvOS) || os(watchOS)
    /// Register for any connection events.
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption: Any]?)
  #endif

  /// Observe for any changes when the system is about to restore the central manager, as part of relaunching the app into the background.
  ///
  /// This method only applies to apps that opt in to the state preservation and restoration feature of Core Bluetooth. The system invokes this method when relaunching your app into the background to complete some Bluetooth-related task. Use this method to synchronize the state of your app with the state of the Bluetooth system.
  ///
  /// - Returns: A Publisher that emits a dictionary that contains information about the central manager preserved by the system when it terminated the app.
  func observeWillRestoreState() -> AnyPublisher<[String: Any], Never>

  /// Observe any update to the ANCS authorization.
  /// This method will trigger an event for any call to the delegate method `centralManager(_:didUpdateANCSAuthorizationFor:)`.
  ///
  /// - Returns: A Publisher that emits a peripheral whose ANCS authorization status changed.
  func observeDidUpdateANCSAuthorization() -> AnyPublisher<BLEPeripheral, Never>
}
