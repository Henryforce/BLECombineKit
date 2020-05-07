//
//  ContentView.swift
//  BLECombineExplorer
//
//  Created by Henry Javier Serrano Echeverria on 2/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import SwiftUI
import CoreBluetooth
import Combine
import BLECombineKit

struct ContentView: View {
    
    @ObservedObject var viewModel: DevicesViewModel
    
    init(with viewModel: DevicesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            DevicesView(viewModel: viewModel)
                .navigationBarTitle(Text("BLE Explorer"))
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: {
                            self.viewModel.startScanning()
                        }
                    ) {
                        Image(systemName: "arrow.clockwise")
                    }
                )
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

