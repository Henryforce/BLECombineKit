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

final class DetailViewModel: ObservableObject {
    
    @Published var temperature = "-"
    @Published var humidity = "-"
    @Published var pressure = "-"
    
    private var disposables = Set<AnyCancellable>()
    var peripheral: BLEPeripheralProtocol?
    
    init() {
        
    }
    
    func startObservingPeripheral() {
        guard let peripheral = peripheral else { return }
        
        let characteristicsObservable = peripheral.connect(with: [:])
            .flatMap { $0.discoverServices(serviceUUIDs: [Constants.serviceUUID]) }
            .flatMap { $0.discoverCharacteristics(characteristicUUIDs: [Constants.temperatureUUID, Constants.humidityUUID, Constants.pressureUUID]) }
            .share()
            .eraseToAnyPublisher()
        
        let temperatureObservable = observeCharacteristic(from: characteristicsObservable, with: Constants.temperatureUUID)
        let humidityObservable = observeCharacteristic(from: characteristicsObservable, with: Constants.humidityUUID)
        let pressureObservable = observeCharacteristic(from: characteristicsObservable, with: Constants.pressureUUID)
        
        Publishers.Zip3(temperatureObservable, humidityObservable, pressureObservable)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { event in
                print(event) // TODO: handle errors
            }, receiveValue: { [weak self] values in
                guard let self = self else { return }
                
                self.temperature = self.stringFormatter(format: Constants.temperatureStringFormat, value: values.0)
                self.humidity = self.stringFormatter(format: Constants.humidityStringFormat, value: values.1)
                self.pressure = self.stringFormatter(format: Constants.pressureStringFormat, value: values.2)
            })
            .store(in: &disposables)
    }
    
    func observeCharacteristic(from characteristicsObservable: AnyPublisher<BLECharacteristic, BLEError>, with characteristicUUID: CBUUID) -> AnyPublisher<Double, BLEError> {
        return characteristicsObservable
            .filter { $0.value.uuid == characteristicUUID }
            .flatMap { $0.observeValueUpdateAndSetNotification() }
            .tryMap { data in
                guard let doubleValue = data.to(type: Float32.self) else { throw BLEError.dataConversionFailed }
                return Double(doubleValue)
            }
            .mapError { $0 as? BLEError ?? BLEError.unknown }
            .eraseToAnyPublisher()
    }
    
    private func stringFormatter(format: String, value: Double) -> String {
        return String(format: format, value)
    }
        
    struct Constants {
        static let serviceUUID = CBUUID.init(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
        static let temperatureUUID = CBUUID.init(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
        static let humidityUUID = CBUUID.init(string: "19B10002-E8F2-537E-4F6C-D104768A1214")
        static let pressureUUID = CBUUID.init(string: "19B10003-E8F2-537E-4F6C-D104768A1214")
        
        static let temperatureStringFormat = "Temperature: %.2f"
        static let humidityStringFormat = "Humidity: %.2f"
        static let pressureStringFormat = "Pressure: %.2f"
    }
    
}
