//
//  CharacteristicDetailViewModel.swift
//  BLECombineExplorer
//
//  Created by Henry Javier Serrano Echeverria on 7/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import SwiftUI
import Combine
import BLECombineKit
import CoreBluetooth

final class CharacteristicDetailViewModel: ObservableObject {
    
    @Published var name = "-"
    @Published var encodedData = "-"
    @Published var hexData = "-"
    
    var characteristic: BLECharacteristic?
    
    private var disposables = Set<AnyCancellable>()
    
    func setup() {
        guard let characteristic = characteristic else { return }
        name = characteristic.value.uuid.uuidString
    }
    
    func readValue() {
        disposables.removeAll()
        
        guard let characteristic = characteristic else { return }
        
        characteristic.observeValue()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { event in
                print(event)
            }, receiveValue: { [weak self] data in
                guard let self = self else { return }
                let encodedData = data.value.base64EncodedString()
                let hexData = data.value.reduce("") { $0 + String(format: "%02x", $1) }
                
                self.encodedData = encodedData
                self.hexData = hexData
            })
            .store(in: &disposables)
    }
    
}
