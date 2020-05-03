//
//  CharacteristicsView.swift
//  BLECombineExplorer
//
//  Created by Henry Javier Serrano Echeverria on 3/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import SwiftUI
import Combine
import BLECombineKit

struct CharacteristicsView: View {
    
    @ObservedObject var viewModel = CharacteristicsViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.characteristics, id: \.value) { characteristic in
                    Text(characteristic.value.uuid.uuidString)
                        .font(.subheadline)
                }
            }.padding()
        }.navigationBarTitle(viewModel.name)
    }
}
