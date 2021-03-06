//
//  WeatherBLESenseViewModel.swift
//  BLECombineExplorer
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import SwiftUI
import Combine
import CoreBluetooth
import BLECombineKit

final class ServicesViewModel: ObservableObject {
    
    @Published var name = "-"
    @Published var services = [BLEService]()
    
    var scanResult: BLEScanResult?
    
    private var cancellables = Set<AnyCancellable>()
    
    func startObservingServices() {
        guard let scanResult = scanResult else { return }
        
        let peripheral = scanResult.peripheral
        
        name = peripheral.peripheral.name ?? "Unknown"
        
        peripheral.connect(with: [:])
            .first()
            .flatMap { $0.discoverServices(serviceUUIDs: nil) }
            .sink(receiveCompletion: { event in
                print(event) // todo: handle error
            }, receiveValue: { [weak self] service in
                guard let self = self else { return }
                self.services.append(service)
            }).store(in: &cancellables)
    }
    
    func reset() {
        if let scanResult = scanResult {
            scanResult.peripheral.disconnect()
        }
        name = "-"
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        services.removeAll()
        scanResult = nil
    }
    
}
