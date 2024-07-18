//
//  BLEPeripheralProvider.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation

protocol BLEPeripheralProvider {
  func provide(
    for peripheralWrapper: CBPeripheralWrapper,
    centralManager: BLECentralManager
  ) -> BLETrackedPeripheral
}

final class StandardBLEPeripheralProvider: BLEPeripheralProvider {

  private lazy var queue = DispatchQueue(
    label: String(describing: StandardBLEPeripheralProvider.self),
    attributes: .concurrent
  )

  private lazy var peripherals = [UUID: StandardBLEPeripheral]()

  func provide(
    for peripheralWrapper: CBPeripheralWrapper,
    centralManager: BLECentralManager
  ) -> BLETrackedPeripheral {
    return existingPeripheral(id: peripheralWrapper.identifier)
      ?? buildPeripheral(for: peripheralWrapper, centralManager: centralManager)
  }

  // MARK - Private.

  private func existingPeripheral(id: UUID) -> StandardBLEPeripheral? {
    queue.sync {
      peripherals[id]
    }
  }

  private func buildPeripheral(
    for peripheralWrapper: CBPeripheralWrapper,
    centralManager: BLECentralManager
  ) -> StandardBLEPeripheral {
    let peripheralDelegate = BLEPeripheralDelegate()
    peripheralWrapper.setupDelegate(peripheralDelegate)

    let blePeripheral = StandardBLEPeripheral(
      peripheral: peripheralWrapper,
      centralManager: centralManager,
      delegate: peripheralDelegate
    )
    queue.async(flags: .barrier) { [weak self] in
      self?.peripherals[peripheralWrapper.identifier] = blePeripheral
    }
    return blePeripheral
  }
}
