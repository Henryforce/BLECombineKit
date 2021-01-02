//
//  BLEPeripheralBuilder.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 2/1/21.
//  Copyright © 2021 Henry Serrano. All rights reserved.
//

import Foundation

protocol BLEPeripheralBuilder {
    func build(
        from peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager
    ) -> BLEPeripheral?
}

final class StandardBLEPeripheralBuilder: BLEPeripheralBuilder {
    func build(
        from peripheral: CBPeripheralWrapper,
        centralManager: BLECentralManager
    ) -> BLEPeripheral? {
        guard let peripheralWrapper = peripheral as? StandardCBPeripheralWrapper else { return nil }

        let peripheralDelegate = BLEPeripheralDelegate()
        peripheralWrapper.setupDelegate(peripheralDelegate)
        
        return BLEPeripheral(
            peripheral: peripheralWrapper,
            centralManager: centralManager,
            delegate: peripheralDelegate
        )
    }
}
