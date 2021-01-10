//
//  BLEError.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum BLEError: Error {
    
    /// Generic error for handling `unknown` cases.
    case unknown
    
    /// Error emitted when publisher turns out to be `nil`.
    case deallocated
    
    // ManagerState
    case bluetoothUnknown
    case bluetoothResetting
    case bluetoothUnsupported
    case bluetoothUnauthorized
    case bluetoothPoweredOff
    
    // Peripheral
    case invalidPeripheral
    case connectionFailure
    case disconnectionFailed
    case servicesFoundError(Error?)
    case characteristicsFoundError(Error?)
    
    // Data
    case invalidData
    case dataConversionFailed
    
    // Write
    case writeFailed(Error)
    
}
