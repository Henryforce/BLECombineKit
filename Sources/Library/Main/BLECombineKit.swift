//
//  BLECombineKit.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 3/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth

public final class BLECombineKit {
    static public func buildCentralManager(with centralManager: CBCentralManager? = nil) -> some BLECentralManager {
        return StandardBLECentralManager(with: centralManager ?? CBCentralManager())
    }
}
