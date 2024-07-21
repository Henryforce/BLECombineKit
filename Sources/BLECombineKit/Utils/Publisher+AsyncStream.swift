//
//  Publisher+AsyncStream.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 19/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

import Combine

extension AnyPublisher {
  var asyncThrowingStream: AsyncThrowingStream<Output, Error> {
    return AsyncThrowingStream { continuation in
      let cancellable =
        self
        .sink { completion in
          if case .failure(let error) = completion {
            continuation.finish(throwing: error)
          }
          else {
            continuation.finish()
          }
        } receiveValue: { data in
          continuation.yield(data)
        }
      continuation.onTermination = { _ in
        cancellable.cancel()
      }
    }
  }
}
