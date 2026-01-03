//
//  BLEPeripheralProvider.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation

protocol BLEPeripheralProvider: Sendable {
  func provide(
    for peripheralWrapper: CBPeripheralWrapper
  ) -> BLETrackedPeripheral
}

final class StandardBLEPeripheralProvider: BLEPeripheralProvider, @unchecked Sendable {

  private lazy var queue = DispatchQueue(
    label: String(describing: StandardBLEPeripheralProvider.self),
    attributes: .concurrent
  )

  private var peripherals = [UUID: StandardBLEPeripheral]()

  weak var centralManager: BLECentralManager?

  init(centralManager: BLECentralManager?) {
    self.centralManager = centralManager
  }

  func provide(
    for peripheralWrapper: CBPeripheralWrapper
  ) -> BLETrackedPeripheral {
    return existingPeripheral(id: peripheralWrapper.identifier)
      ?? buildPeripheral(for: peripheralWrapper)
  }

  // MARK - Private.

  private func existingPeripheral(id: UUID) -> StandardBLEPeripheral? {
    queue.sync {
      peripherals[id]
    }
  }

  private func buildPeripheral(
    for peripheralWrapper: CBPeripheralWrapper
  ) -> StandardBLEPeripheral {
    let peripheralDelegate = BLEPeripheralDelegate()
    peripheralWrapper.setupDelegate(peripheralDelegate)

    let blePeripheral = StandardBLEPeripheral(
      peripheral: peripheralWrapper,
      centralManager: centralManager,
      delegate: peripheralDelegate
    )
    let uncheckedPeripheralWrapper = UncheckedSendable(peripheralWrapper)
    queue.sync(flags: .barrier) {
      self.peripherals[uncheckedPeripheralWrapper.value.identifier] = blePeripheral
    }
    return blePeripheral
  }
}

private struct UncheckedSendable<T>: @unchecked Sendable {
  let value: T
  init(_ value: T) { self.value = value }
}
