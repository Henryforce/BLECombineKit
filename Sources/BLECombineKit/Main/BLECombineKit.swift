//
//  BLECombineKit.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 3/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import CoreBluetooth
import Foundation

public enum BLECombineKit {
  /// Build a BLECentralManager from which to scan peripherals.
  ///
  /// - Parameters:
  ///   - centralManager: An optional CBCentralManager object, if available.
  ///
  /// - Returns: an initialized BLECentralManager object.
  static public func buildCentralManager(
    with centralManager: CBCentralManager? = nil
  ) -> BLECentralManager {
    return StandardBLECentralManager(with: centralManager ?? CBCentralManager())
  }

  /// Build a BLEPeripheralManager.
  ///
  /// - Returns: an initialized BLEPeripheralManager object.
  static public func buildPeripheralManager() -> BLEPeripheralManager {
    return StandardBLEPeripheralManager()
  }
}
