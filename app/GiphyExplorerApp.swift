//
//  GiphyExplorerApp.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 31/05/2022.
//

import SwiftUI

import Looping
import LoopingWebP

@main
struct GiphyExplorerApp: App {
    
    init() {
        LoopImage.enableWebP()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
