//
//  BLECombineKit+Combine.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 21/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine

extension BLECombineKit {
  /// A convenient method for creating a Combine's `Just` which defines the failure as `BLEError`
  /// and the output type as the given input's type.
  /// This method saves the declaration of `setFailureType` followed by `eraseToAnyPublisher`.
  static func Just<T>(_ value: T) -> AnyPublisher<T, BLEError> {
    Combine.Just(value)
      .setFailureType(to: BLEError.self)
      .eraseToAnyPublisher()
  }

  static func OutputOrFail<T>(output: T, error: BLEError?) -> AnyPublisher<T, BLEError> {
    if let error = error {
      return Fail(error: error).eraseToAnyPublisher()
    }
    return BLECombineKit.Just(output)
  }
}
