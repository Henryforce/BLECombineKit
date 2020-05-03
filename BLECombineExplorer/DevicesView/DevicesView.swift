//
//  DevicesView.swift
//  BLECombineExplorer
//
//  Created by Henry Javier Serrano Echeverria on 3/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import SwiftUI
import Combine
import BLECombineKit

struct DevicesView: View {
    
    @ObservedObject var viewModel: DevicesViewModel
    @ObservedObject var servicesViewModel = ServicesViewModel()
    @State private var actionState: ActionState? = .setup
    
    var body: some View {
        VStack {
            NavigationLink(destination: ServicesView(viewModel: servicesViewModel), tag: .readyForPush, selection: $actionState) {
                EmptyView()
            }
            List {
                ForEach(viewModel.peripherals, id: \.name) { item in
                    ItemView(peripheral: item)
                        .onTapGesture {
                            self.itemViewWasTapped(with: item)
                        }
                }
            }
        }.onAppear() {
            self.servicesViewModel.reset()
        }
    }
    
    private func itemViewWasTapped(with item: ScannedPeripheralItem) {
        viewModel.stopScan()
        servicesViewModel.scanResult = viewModel.blePeripheralMap[item.identifier]
        servicesViewModel.startObservingServices()
        actionState = .readyForPush
    }
}

struct ItemView: View {
    let peripheral: ScannedPeripheralItem
    
    var body: some View {
        VStack {
            HStack {
                Text(peripheral.name)
                    .font(.title)
                Spacer()
            }
            HStack {
                Text(peripheral.identifier.uuidString)
                    .font(.footnote)
                Spacer()
                Text(String(peripheral.rssi))
                    .font(.subheadline)
            }
        }.padding()
    }
}
