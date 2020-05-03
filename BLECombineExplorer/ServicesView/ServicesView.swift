//
//  DetailView.swift
//  BLECombineExplorer
//
//  Created by Henry Javier Serrano Echeverria on 3/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import SwiftUI
import BLECombineKit
import Combine

struct ServicesView: View {
    
    @ObservedObject var viewModel: ServicesViewModel
    @ObservedObject var characteristicsViewModel = CharacteristicsViewModel()
    @State private var actionState: ActionState? = .setup
    
    var body: some View {
        VStack {
            NavigationLink(destination: CharacteristicsView(viewModel: characteristicsViewModel),
                           tag: .readyForPush,
                           selection: $actionState) {
                EmptyView()
            }
            List {
                ForEach(viewModel.services, id: \.value) { service in
                    HStack {
                        Text(service.value.uuid.uuidString)
                            .font(.subheadline)
                    }.onTapGesture {
                        self.characteristicsViewModel.service = service
                        self.characteristicsViewModel.startObservingCharacteristics()
                        self.actionState = .readyForPush
                    }
                }
            }.padding()
        }.onAppear {
            self.characteristicsViewModel.reset()
        }
        .navigationBarTitle(viewModel.name)
    }
    
}
