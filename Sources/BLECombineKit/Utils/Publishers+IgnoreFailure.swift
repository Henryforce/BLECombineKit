//
//  Publishers+IgnoreFailure.swift
//  BLECombineKit
//
//  Copied by Henry Serrano on 13/07/2024.
//  Created by Jasdev Singh on 17/10/2020.
//  Copyright © 2020 Combine Community. All rights reserved.
//
//  Original method found on https://github.com/CombineCommunity/CombineExt
//

import Combine

extension Publisher {
  /// An analog to `ignoreOutput` for `Publisher`’s `Failure` generic, allowing for either no or an immediate completion on an error event.
  ///
  /// - parameter completeImmediately: Whether the returned publisher should complete on an error event. Defaults to `true`.
  ///
  /// - returns: A publisher that ignores upstream error events.
  func ignoreFailure(completeImmediately: Bool = true) -> AnyPublisher<Output, Never> {
    `catch` { _ in Empty(completeImmediately: completeImmediately) }
      .eraseToAnyPublisher()
  }

}
