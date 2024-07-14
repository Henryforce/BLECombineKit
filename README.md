# BLECombineKit

![badge-platforms][] [![badge-spm][]][spm]

CoreBluetooth abstraction layer for iOS and macOS development environments.

- Swift Concurrency compatible
- SwiftUI compatible
- Apple's APIs dependencies only

It is currently supported on:

iOS 13.0+
macOS 10.15+

# How to use

As simple as creating a CBCentralManager and let the reactive magic of Combine do the rest:

```swift
import CoreBluetooth
import Combine
import BLECombineKit

...

let centralManager = BLECombineKit.buildCentralManager(with: CBCentralManager())

let serviceUUID = CBUUID(string: "0x00FF")
// Connect to the first peripheral that matches the given service UUID and observe all the
// characteristics in that service.
centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    .first()
    .flatMap { $0.peripheral.connect(with: nil) }
    .flatMap { $0.discoverServices(serviceUUIDs: [serviceUUID]) }
    .flatMap { $0.discoverCharacteristics(characteristicUUIDs: nil) }
    .flatMap { $0.observeValue() }
    .sink(receiveCompletion: { completion in
        print(completion)
    }, receiveValue: { data in
        print(data.value)
    })
    .store(in: &disposables)
```

And with Swift Concurrency, it would look like this:

```swift
import CoreBluetooth
import Combine
import BLECombineKit

...

let centralManager = BLECombineKit.buildCentralManager(with: CBCentralManager())

let serviceUUID = CBUUID(string: "0x00FF")
// Connect to the first peripheral that matches the given service UUID and observe all the
// characteristics in that service.
let stream = centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    .first()
    .flatMap { $0.peripheral.connect(with: nil) }
    .flatMap { $0.discoverServices(serviceUUIDs: [serviceUUID]) }
    .flatMap { $0.discoverCharacteristics(characteristicUUIDs: nil) }
    .flatMap { $0.observeValue() }
    .values
    
Task {
  for try await value in stream {
    print("Value received \(value)")
  }
}
```

# Installation

## Swift Package Manager

In Xcode, select File --> Swift Packages --> Add Package Dependency and then add the following url:

```swift
https://github.com/Henryforce/BLECombineKit
```

[badge-platforms]: https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20-lightgrey.svg
[badge-carthage]: https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat
[badge-spm]: https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg

[carthage]: https://github.com/Carthage/Carthage
[spm]: https://github.com/apple/swift-package-manager
