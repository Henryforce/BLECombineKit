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
    
    private var disposables = Set<AnyCancellable>()
    
    func startObservingServices() {
        reset()
        
        guard let scanResult = scanResult else { return }
        
        let peripheral = scanResult.peripheral
        
        name = peripheral.peripheral.name ?? "Unknown"
        
        peripheral.connect(with: [:])
            .flatMap { $0.discoverServices(serviceUUIDs: []) }
            .sink(receiveCompletion: { event in
                print(event) // todo: handle error
            }, receiveValue: { [weak self] service in
                guard let self = self else { return }
                self.services.append(service)
            })
            .store(in: &disposables)
    }
    
    func reset() {
        if let scanResult = scanResult {
            _ = scanResult.peripheral.disconnect()
        }
        name = "-"
        disposables.removeAll()
        services.removeAll()
    }
    
}
