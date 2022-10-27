//
//  ContentView.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 31/05/2022.
//

import SwiftUI
import Looping
import LoopingWebP

struct ContentView: View {
    @StateObject private var model = ContentViewModel()
    
    var body: some View {
        NavigationView {
            GridView(model: model.gridViewModel)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Giphy Explorer")
        }
        .navigationViewStyle(.stack)
        .searchable(text: $model.userSearchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Trending feed from Giphy")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
