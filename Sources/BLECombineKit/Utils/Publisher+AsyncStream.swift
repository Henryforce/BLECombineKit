//
//  Publisher+AsyncStream.swift
//  BLECombineKit
//
//  Created by Henry Javier Serrano Echeverria on 19/7/24.
//  Copyright © 2024 Henry Serrano. All rights reserved.
//

@preconcurrency import Combine

extension AnyPublisher where Output: Sendable {
  var asyncThrowingStream: AsyncThrowingStream<Output, Error> {
    return AsyncThrowingStream { continuation in
      let cancellable =
        self
        .sink { completion in
          if case .failure(let error) = completion {
            continuation.finish(throwing: error)
          } else {
            continuation.finish()
          }
        } receiveValue: { data in
          continuation.yield(data)
        }

      let uncheckedCancellable = UncheckedSendable(cancellable)
      continuation.onTermination = { _ in
        uncheckedCancellable.value.cancel()
      }
    }
  }
}

private struct UncheckedSendable<T>: @unchecked Sendable {
  let value: T
  init(_ value: T) { self.value = value }
}
