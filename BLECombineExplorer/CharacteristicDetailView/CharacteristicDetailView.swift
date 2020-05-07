//
//  CharacteristicDetailView.swift
//  BLECombineExplorer
//
//  Created by Henry Javier Serrano Echeverria on 7/5/20.
//  Copyright © 2020 Henry Serrano. All rights reserved.
//

import SwiftUI

struct CharacteristicDetailView: View {
    
    @ObservedObject var viewModel: CharacteristicDetailViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                self.viewModel.readValue()
            }) {
                Text("Read Value")
            }
            DataStringView(title: "Encoded Data: ", dataString: viewModel.encodedData)
            DataStringView(title: "Hex Data: ", dataString: viewModel.hexData)
        }
    }
    
}

struct DataStringView: View {
    
    var title: String
    var dataString: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Text(dataString)
                .font(.subheadline)
        }.frame(alignment: .center)
    }
    
}
