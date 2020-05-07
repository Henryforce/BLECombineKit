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
    
    @ObservedObject var viewModel: CharacteristicsViewModel
    @ObservedObject var characteristicDetailViewModel = CharacteristicDetailViewModel()
    @State private var actionState: ActionState? = .setup
    
    var body: some View {
        VStack {
            NavigationLink(destination: CharacteristicDetailView(viewModel: characteristicDetailViewModel),
                           tag: .readyForPush,
                           selection: $actionState) {
                EmptyView()
            }
            List {
                ForEach(viewModel.characteristics, id: \.value) { characteristic in
                    Text(characteristic.value.uuid.uuidString)
                        .font(.subheadline)
                        .onTapGesture {
                            self.characteristicDetailViewModel.characteristic = characteristic
                            self.characteristicDetailViewModel.setup()
                            self.actionState = .readyForPush
                        }
                }
            }.padding()
        }.navigationBarTitle(viewModel.name)
    }
}
