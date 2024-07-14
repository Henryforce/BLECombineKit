//
//  Publishers+SetOutputType.swift
//  BLECombineKit
//
//  Copied by Henry Serrano on 13/07/2024.
//  Created by Jasdev Singh on 02/04/2020.
//  Copyright © 2020 Combine Community. All rights reserved.
//
//  Original method found on https://github.com/CombineCommunity/CombineExt
//

import Combine

extension Publisher where Output == Never {
  /// An output analog to [Publisher.setFailureType(to:)](https://developer.apple.com/documentation/combine/publisher/3204753-setfailuretype) for when `Output == Never`. This is especially helpful when chained after [.ignoreOutput()](https://developer.apple.com/documentation/combine/publisher/3204714-ignoreoutput) operator calls.
  ///
  /// - parameter outputType: The new output type for downstream.
  ///
  /// - returns: A publisher with a `NewOutput` output type.
  func setOutputType<NewOutput>(to outputType: NewOutput.Type) -> Publishers.Map<Self, NewOutput> {
    map { _ -> NewOutput in }
  }
}
