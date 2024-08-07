//
//  BLECentral.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 06/08/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import CoreBluetooth

public protocol BLECentral {
  /// Reference to the actual central. Use this getter to obtain the CBCentral if needed. Note that CBCentral conforms to BLECentral.
  var associatedCentral: CBCentral? { get }

  /// The UUID associated with the peer.
  var identifier: UUID { get }

  /// The maximum amount of data, in bytes, that can be received by the central in a single notification or indication.
  var maximumUpdateValueLength: Int { get }
}

extension CBCentral: BLECentral {
  public var associatedCentral: CBCentral? { self }
}
