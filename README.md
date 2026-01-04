# BLECombineKit

![badge-platforms][] [![badge-spm][]][spm]

CoreBluetooth abstraction layer for iOS and macOS development environments.

- Swift Concurrency compatible
- SwiftUI compatible
- Apple's APIs dependencies only

It is currently supported on:

iOS 13.0+
macOS 10.15+

# Architecture Overview

BLECombineKit wraps CoreBluetooth with a reactive layer using Combine and providing modern Swift Concurrency (Async/Await) extensions.

- **BLECentralManager**: A wrapper for `CBCentralManager` that handles scanning and connecting to peripherals.
- **BLEPeripheral**: A wrapper for `CBPeripheral` that facilitates service and characteristic discovery, and data operations.
- **BLEService**: A wrapper for `CBService`.
- **BLECharacteristic**: A wrapper for `CBCharacteristic`.
- **BLEPeripheralManager**: A wrapper for `CBPeripheralManager` to act as a Bluetooth peripheral.

# How to use

### Central Manager (Scanning and Connecting)

As simple as creating a `CBCentralManager` and letting the reactive magic of Combine do the rest:

```swift
import CoreBluetooth
import Combine
import BLECombineKit

let centralManager = BLECombineKit.buildCentralManager(with: CBCentralManager())

let serviceUUID = CBUUID(string: "0x00FF")
let characteristicUUID = CBUUID(string: "0xFF01")

centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    .first()
    .flatMap { $0.peripheral.connect(with: nil) }
    .flatMap { $0.discoverServices(serviceUUIDs: [serviceUUID]) }
    .flatMap { $0.discoverCharacteristics(characteristicUUIDs: nil) }
    .filter { $0.value.uuid == characteristicUUID }
    .flatMap { $0.observeValueUpdateAndSetNotification() }
    .sink(receiveCompletion: { completion in
        print(completion)
    }, receiveValue: { data in
        print(data.value)
    })
    .store(in: &disposables)
```

### Swift Concurrency

With Swift Concurrency, you can use `AsyncThrowingStream` and `async/await`:

```swift
let stream = centralManager.scanForPeripheralsStream(withServices: [serviceUUID], options: nil)
    
Task {
    do {
        // Connect to all the peripherals found matching the service UUID.
        // This is just an example so you can also just wait for the first peripheral
        // found instead of using a for loop.  
        for try await peripheral in stream {
            let connected = try await centralManager.connectAsync(peripheral: peripheral)
            let services = try await connected.discoverServicesAsync(serviceUUIDs: [serviceUUID])
            
            for service in services {
                let characteristics = try await service.discoverCharacteristicsAsync(characteristicUUIDs: nil)
                // ... interact with characteristics
            }
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### Writing Data

You can write data to characteristics using either Combine or Async/Await:

```swift
// Combine
characteristic.writeValue(someData, type: .withResponse)
    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    .store(in: &disposables)

// Async/Await
try await characteristic.writeValueAsync(someData, type: .withResponse)
```

### Peripheral Manager (Advertising)

Act as a peripheral and advertise services:

```swift
let peripheralManager = BLECombineKit.buildPeripheralManager()

let advertisementData: [String: Any] = [
    CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
    CBAdvertisementDataLocalNameKey: "MyPeripheral"
]

peripheralManager.startAdvertising(advertisementData)
    .sink(receiveCompletion: { _ in }, receiveValue: { result in
        print("Advertising status: \(result)")
    })
    .store(in: &disposables)
```

# Error Handling

BLECombineKit provides a structured `BLEError` enum that categorizes errors from different parts of the stack:

- `.managerState`: Issues with Bluetooth state (powered off, unauthorized, etc.)
- `.peripheral`: Issues during connection, discovery, or communication.
- `.data`: Data conversion failures.
- `.writeFailed`: Explicit write operation failures.

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
