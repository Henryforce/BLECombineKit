//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

typealias DidDiscoverAdvertisementDataResult = (peripheral: CBPeripheralWrapper, advertisementData: [String: Any], rssi: NSNumber)

public final class BLECentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    
    let didConnectPeripheral = PassthroughSubject<CBPeripheralWrapper, Never>()
    let didDisconnectPeripheral = PassthroughSubject<CBPeripheralWrapper, Never>()
    let didFailToConnect = PassthroughSubject<CBPeripheralWrapper, Error>()
    let didDiscoverAdvertisementData = PassthroughSubject<DidDiscoverAdvertisementDataResult, Never>()
    let didUpdateState = PassthroughSubject<ManagerState, Never>()

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didConnectPeripheral.send(peripheralWrapper)
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didDisconnectPeripheral.send(peripheralWrapper)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        didFailToConnect.send(peripheralWrapper)
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let peripheralWrapper = StandardCBPeripheralWrapper(peripheral: peripheral)
        let result = (peripheral: peripheralWrapper, advertisementData: advertisementData, rssi: RSSI)
        didDiscoverAdvertisementData.send(result)
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let state = ManagerState(rawValue: central.state.rawValue) else { return }
        didUpdateState.send(state)
    }

}
