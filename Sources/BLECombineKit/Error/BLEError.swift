//
//  BLEError.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 1/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

@preconcurrency import CoreBluetooth
import Foundation

extension NSError: @retroactive Identifiable {

}

extension CBError: @retroactive Hashable, @retroactive Identifiable {
  public var id: Self { self }
}

extension CBATTError: @retroactive Hashable, @retroactive Identifiable {
  public var id: Self { self }
}

/// Represents errors that can occur within the BLECombineKit framework.
public enum BLEError: Error, CustomStringConvertible {

  /// Errors related to the underlying CoreBluetooth framework.
  public enum CoreBluetoothError: Error, Hashable, Identifiable, CustomStringConvertible {
    case base(code: CBError.Code, description: String), ATT(
      code: CBATTError.Code,
      description: String
    ), other(error: NSError)

    public var id: Self { self }

    static func from(error: NSError) -> CoreBluetoothError {
      switch error.domain {
      case CBErrorDomain:
        return .base(
          code: CBError.Code(rawValue: error.code)!,
          description: error.localizedDescription
        )
      case CBATTErrorDomain:
        return .ATT(
          code: CBATTError.Code(rawValue: error.code)!,
          description: error.localizedDescription
        )
      default: return .other(error: error)
      }
    }

    public var description: String {
      switch self {
      case .base(let code, let description):
        return
          "CBError, code \(String(format: "0x%02X", code.rawValue)), description: \(description)"
      case .ATT(let code, let description):
        return
          "CBATTError, code \(String(format: "0x%02X", code.rawValue)), description: \(description)"
      case .other(let error):
        return
          "Other error, domain \"\(error.domain)\" code \(error.code), description: \(error.description)"
      }
    }
  }

  /// Errors related to the Bluetooth manager's state.
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

  /// Errors related to peripheral operations.
  public enum PeripheralError: Error, Hashable, Identifiable, CustomStringConvertible {
    public var id: Self { self }
    case invalid
    case connectionFailure
    case disconnectionFailed
    case didDiscoverDescriptorsError(CoreBluetoothError)
    case didUpdateValueForCharacteristicError(CoreBluetoothError)
    case didUpdateValueForDescriptorError(CoreBluetoothError)
    case servicesFoundError(CoreBluetoothError)
    case characteristicsFoundError(CoreBluetoothError)
    case writeError(CoreBluetoothError)
    case readRSSIError(CoreBluetoothError)

    public var description: String {
      switch self {
      case .invalid: "Invalid"
      case .connectionFailure: "Connection Failure"
      case .disconnectionFailed: "Disconnection Failed"
      case .didDiscoverDescriptorsError(let error): "Did Discover Descriptors Error: \(error)"
      case .didUpdateValueForCharacteristicError(let error):
        "Did Update Value for Characteristic Error:  \(error)"
      case .didUpdateValueForDescriptorError(let error):
        "Did Update Value for Descriptor Error: \(error)"
      case .servicesFoundError(let error): "Services Found Error: \(error)"
      case .characteristicsFoundError(let error): "Characteristics Found Error: \(error)"
      case .writeError(let error): "Write Error: \(error)"
      case .readRSSIError(let error): "Read RSSI Error: \(error)"
      }
    }
  }

  /// Errors related to data conversion or validation.
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

  /// Error emitted when advertising is already in progress.
  case advertisingInProgress

  /// Error emitted when advertising fails to start.
  case advertisingStartFailed(Error)

  /// Error emitted when adding a service fails.
  case addingServiceFailed(CBMutableService, Error)

  /// Error emitted when publishing an L2CAP channel fails.
  case publishingL2CAPChannelFailed(CBL2CAPPSM, Error)

  /// Generic error for handling `unknown` cases.
  case unknown

  /// Error emitted when the underlying manager or peripheral is deallocated.
  case deallocated

  /// Error related to the manager state.
  case managerState(ManagerStateError)

  /// Error related to a peripheral.
  case peripheral(PeripheralError)

  /// Error related to data operations.
  case data(DataError)

  /// Error emitted when a write operation fails.
  case writeFailed(CoreBluetoothError)

  public var description: String {
    switch self {
    case .advertisingInProgress: return "Advertising in Progress"
    case .advertisingStartFailed(let error):
      return "Advertising failed to start with error: \(error)"
    case .addingServiceFailed(let service, let error):
      return "Adding service \(service) failed with error: \(error)"
    case .publishingL2CAPChannelFailed(_, let error):
      return "Publishing L2CAPChannel failed with error: \(error)"
    case .unknown: return "Unknown error"
    case .deallocated: return "Deallocated"
    case .managerState(let error): return "Manager state error: \(error)"
    case .peripheral(let error): return "Peripheral error: \(error)"
    case .data(let error): return "Data error: \(error)"
    case .writeFailed(let error): return "Write failed: \(error)"
    }
  }

}
