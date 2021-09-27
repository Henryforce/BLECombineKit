//
//  BLEError.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth

extension NSError: Identifiable {
    
}

extension CBError: Hashable, Identifiable {
    public var id: Self { self }
}

extension CBATTError: Hashable, Identifiable {
    public var id: Self { self }
}

public enum BLEError: Error, Hashable, Identifiable, CustomStringConvertible {
    public enum CoreBluetoothError: Error, Hashable, Identifiable, CustomStringConvertible {
        case base(code: CBError.Code, description: String), ATT(code: CBATTError.Code, description: String), other(error: NSError)
        
        public var id: Self { self }
        
        static func from(error: NSError) -> CoreBluetoothError {
            switch(error.domain) {
            case CBErrorDomain: return .base(code: CBError.Code(rawValue: error.code)!, description: error.localizedDescription)
            case CBATTErrorDomain: return .ATT(code: CBATTError.Code(rawValue: error.code)!, description: error.localizedDescription)
            default: return .other(error: error)
            }
        }
        
        public var description: String {
            switch self {
            case .base(code: let code, description: let description): return "CBError, code \(code), description: \(description)"
            case .ATT(code: let code, description: let description): return "CBATTError, code \(code), description: \(description)"
            case .other(error: let error): return "Other error, domain \"\(error.domain)\" code \(error.code), description: \(error.description)"
            }
        }
    }
    
    public enum ManagerStateError: Error, Hashable, Identifiable, CustomStringConvertible {
        public var id: Self { self }
        case unknown
        case resetting
        case unsupported
        case unauthorized
        case poweredOff
        
        public var description: String {
            switch self {
            case .unknown: return "Unknown"
            case .resetting: return "Resetting"
            case .unsupported: return "Unsupported"
            case .unauthorized: return "Unauthorized"
            case .poweredOff: return "Powered Off"
            }
        }
    }
    
    public enum PeripheralError: Error, Hashable, Identifiable, CustomStringConvertible {
        public var id: Self { self }
        case invalid
        case connectionFailure
        case disconnectionFailed
        case servicesFoundError(CoreBluetoothError)
        case characteristicsFoundError(CoreBluetoothError)
        
        public var description: String {
            switch self {
            case .invalid: return "Invalid"
            case .connectionFailure: return "Connection Failure"
            case .disconnectionFailed: return "Disconnection Failed"
            case .servicesFoundError(let error): return "Services Found Error: \(error)"
            case .characteristicsFoundError(let error): return "Characteristics Found Error: \(error)"
            }
        }
    }
    
    public enum DataError: Error, Hashable, Identifiable, CustomStringConvertible {
        public var id: Self { self }
        case invalid
        case conversionFailed
        
        public var description: String {
            switch self {
            case .invalid: return "Invalid"
            case .conversionFailed: return "Conversion Failed"
            }
        }
    }
    
    public var id: Self { self }
    
    /// Generic error for handling `unknown` cases.
    case unknown
    
    /// Error emitted when publisher turns out to be `nil`.
    case deallocated
    
    // ManagerState
    case managerState(ManagerStateError)
    
    // Peripheral
    case peripheral(PeripheralError)
    
    // Data
    case data(DataError)
    
    // Write
    case writeFailed(CoreBluetoothError)
    
    public var description: String {
        switch(self) {
        case .unknown: return "Unknown error"
        case .deallocated: return "Deallocated"
        case .managerState(let error): return "Manager state error: \(error)"
        case .peripheral(let error): return "Peripheral error: \(error)"
        case .data(let error): return "Data error: \(error)"
        case .writeFailed(let error): return "Write failed: \(error)"
        }
    }
    
}
