//
//  BLECombineKit.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 3/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum BLECombineKit {
    static public func buildCentralManager(
      with centralManager: CBCentralManager? = nil
    ) -> BLECentralManager {
        return StandardBLECentralManager(with: centralManager ?? CBCentralManager())
    }
}
