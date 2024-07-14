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
    for peripheral: CBPeripheralWrapper,
    centralManager: BLECentralManager
  ) -> BLETrackedPeripheral
}

final class StandardBLEPeripheralProvider: BLEPeripheralProvider {

  private lazy var queue = DispatchQueue(
    label: String(describing: StandardBLEPeripheral.self),
    attributes: .concurrent
  )

  private var peripherals = [UUID: BLETrackedPeripheral]()

  func provide(
    for peripheral: CBPeripheralWrapper,
    centralManager: BLECentralManager
  ) -> BLETrackedPeripheral {
    return existingPeripheral(id: peripheral.identifier)
      ?? {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral.peripheral)
        let peripheralDelegate = BLEPeripheralDelegate()
        peripheralWrapper.setupDelegate(peripheralDelegate)

        let blePeripheral = StandardBLEPeripheral(
          peripheral: peripheralWrapper,
          centralManager: centralManager,
          delegate: peripheralDelegate
        )
        queue.async(flags: .barrier) { [weak self] in
          self?.peripherals[peripheral.identifier] = blePeripheral
        }
        return blePeripheral
      }()
  }

  private func existingPeripheral(id: UUID) -> BLETrackedPeripheral? {
    queue.sync {
      peripherals[id]
    }
  }
}
