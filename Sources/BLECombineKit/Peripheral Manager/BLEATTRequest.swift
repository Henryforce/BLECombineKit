//
//  BLEATTRequest.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 06/08/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import CoreBluetooth

public protocol BLEATTRequest {
  /// Reference to the actual request. Use this getter to obtain the CBATTRequest if needed. Note that CBATTRequest conforms to BLEATTRequest.
  var associatedRequest: CBATTRequest? { get }

  /// The wrapper of the central that originated the request.
  var centralWrapper: BLECentral { get }

  /// The characteristic whose value will be read or written.
  var characteristic: CBCharacteristic { get }

  /// The zero-based index of the first byte for the read or write.
  var offset: Int { get }

  /// The data being read or written. For read requests, <i>value</i> will be nil and should be set before responding via @link respondToRequest:withResult: @/link. For write requests, <i>value</i> will contain the data to be written.
  var value: Data? { get set }
}

extension CBATTRequest: BLEATTRequest {
  public var associatedRequest: CBATTRequest? { self }

  public var centralWrapper: BLECentral {
    central
  }
}
