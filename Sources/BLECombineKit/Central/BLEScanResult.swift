//
//  BLEScanResult.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation

/// Represents the result of a peripheral scan.
public struct BLEScanResult {
  /// The discovered peripheral.
  public let peripheral: BLEPeripheral
  /// The advertisement data associated with the scan result.
  public let advertisementData: [String: Any]
  /// The RSSI (Received Signal Strength Indicator) of the peripheral at the time of discovery.
  public let rssi: NSNumber

  public init(peripheral: BLEPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
    self.peripheral = peripheral
    self.advertisementData = advertisementData
    self.rssi = rssi
  }
}
