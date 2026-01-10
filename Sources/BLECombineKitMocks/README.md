# BLECombineKitMocks

This directory contains mock implementations of the protocols defined in `BLECombineKit`. These mocks are designed to facilitate unit testing of your Bluetooth-related logic without requiring actual hardware or complex CoreBluetooth boilerplate.

## Overview

The mocks follow a consistent pattern:
- **WasCalledCount**: Tracks how many times a method was called.
- **ReturnValue**: Allows you to specify the result (Publisher or value) that a method should return.
- **Captured Arguments**: Properties like `lastCalledPeripheral` or `lastCalledUUIDs` capture the arguments passed to method calls for verification.

## Usage Examples

### Mocking BLECentralManager

You can use `MockBLECentralManager` to simulate peripheral discovery and connection.

```swift
import XCTest
import Combine
import BLECombineKit
import BLECombineKitMocks

class MyBluetoothServiceTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    
    func testStartScanning() {
        // Given
        let mockCentral = MockBLECentralManager()
        let service = MyBluetoothService(centralManager: mockCentral)
        
        let scanResult = BLEScanResult(
            peripheral: MockBLEPeripheral(),
            advertisementData: [:],
            rssi: -50
        )
        mockCentral.scanForPeripheralsReturnValue = Just(scanResult)
            .setFailureType(to: BLEError.self)
            .eraseToAnyPublisher()
        
        // When
        service.startScanning()
        
        // Then
        XCTAssertEqual(mockCentral.scanForPeripheralsWasCalledCount, 1)
    }
}
```

### Mocking BLEPeripheral

`MockBLEPeripheral` allows you to simulate service discovery, characteristic reading/writing, and notifications.

```swift
func testReadCharacteristic() {
    // Given
    let mockPeripheral = MockBLEPeripheral()
    let characteristic = CBMutableCharacteristic(type: CBUUID(string: "EEE1"), properties: .read, value: nil, permissions: .readable)
    
    let expectedData = Data([0x01, 0x02])
    mockPeripheral.readValueReturnValue = Just(BLEData(value: expectedData, peripheral: mockPeripheral))
        .setFailureType(to: BLEError.self)
        .eraseToAnyPublisher()
    
    // When
    var receivedData: Data?
    mockPeripheral.readValue(for: characteristic)
        .sink(receiveCompletion: { _ in }, receiveValue: { bleData in
            receivedData = bleData.value
        })
        .store(in: &cancellables)
    
    // Then
    XCTAssertEqual(receivedData, expectedData)
    XCTAssertEqual(mockPeripheral.readValueWasCalledCount, 1)
    XCTAssertEqual(mockPeripheral.readValueCharacteristic, characteristic)
}
```

### Mocking BLEPeripheralManager

If you are building a peripheral application, `MockBLEPeripheralManager` helps test advertising and responding to requests.

```swift
func testStartAdvertising() {
    // Given
    let mockPeripheralManager = MockBLEPeripheralManager()
    mockPeripheralManager.startAdvertisingReturnValue = Just(.started)
        .setFailureType(to: BLEError.self)
        .eraseToAnyPublisher()
    
    // When
    mockPeripheralManager.startAdvertising(["localName": "TestDevice"])
        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        .store(in: &cancellables)
    
    // Then
    XCTAssertEqual(mockPeripheralManager.startAdvertisingWasCalledCount, 1)
    XCTAssertEqual(mockPeripheralManager.startAdvertisingData?["localName"] as? String, "TestDevice")
}
```

## Installation

To use these mocks in your test target, add `BLECombineKitMocks` to your dependencies in `Package.swift`:

```swift
.testTarget(
    name: "YourAppTests",
    dependencies: [
        "YourApp",
        .product(name: "BLECombineKitMocks", package: "BLECombineKit")
    ]
)
```
