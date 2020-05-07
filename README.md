# BLECombineKit

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Build Status](https://travis-ci.com/Henryforce/BLECombineKit.svg?branch=master)](https://travis-ci.com/Henryforce/BLECombineKit) 

CoreBluetooth abstraction layer for iOS, macOS, TvOS and WatchOS development environments. Powered by Combine.

- SwiftUI compatible
- Apple's APIs dependencies only

# How to use [Work in Progress]

As simple as creating a CBCentralManager and let the reactive magic of Combine do the rest:

```
import CoreBluetooth
import Combine
import BLECombineKit

...

let centralManager = BLECombineKit.buildCentralManager(with: CBCentralManager())

centralManager.scanForPeripherals(withServices: nil, options: nil)
    .first()
    .flatMap { $0.peripheral.discoverServices(serviceUUIDs: nil) }
    .flatMap { $0.discoverCharacteristics(characteristicUUIDs: nil) }
    .flatMap { $0.observeValue() }
    .sink(receiveCompletion: { completion in
        print(completion)
    }, receiveValue: { data in
        print(data.value)
    })
    .store(in: &disposables)
```

You can reference the sample project inside the repository to see the library in action with SwiftUI.

# Installation

## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.
To integrate CombineBluetoothKit into your Xcode project using Carthage  specify it in your `Cartfile`:
```swift
github "Henryforce/BLECombineKit"
```
Then, run `carthage update` to build framework and drag `CombineBluetoothKit.framework` into your Xcode project.
