//
//  CharacteristicsViewModel.swift
//  BLECombineExplorer
//
//  Created by Henry Javier Serrano Echeverria on 3/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import Combine
import BLECombineKit

final class CharacteristicsViewModel: ObservableObject {
    
    @Published var name = "-"
    @Published var characteristics = [BLECharacteristic]()
    
    var service: BLEService?
    
    private var disposables = Set<AnyCancellable>()
    
    func startObservingCharacteristics() {
        reset()
        
        guard let service = service else { return }
        
        name = service.value.uuid.uuidString
        
        service.discoverCharacteristics(characteristicUUIDs: nil)
            .sink(receiveCompletion: { event in
                print(event) // todo: handle error
            }, receiveValue: { [weak self] characteristic in
                guard let self = self else { return }
                self.characteristics.append(characteristic)

            })
            .store(in: &disposables)
    }
    
    func reset() {
        name = "-"
        disposables.removeAll()
        characteristics.removeAll()
    }
    
}
