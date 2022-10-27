//
//  HQView.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 31/05/2022.
//

import SwiftUI

import Looping
import LoopingWebP

struct HQView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let urlString: String
    
    @State private var loop: Loop<EmptyView>?
    
    var body: some View {
        NavigationView {
            ZStack {
                ProgressView()
                
                loop?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .task(loadImage)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
            }
        }
    }
    
    @Sendable func loadImage() async {
        print("Loading HQ Image data from Giphy")
        do {
            guard let url = URL(string: self.urlString) else {
                return
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            self.loop = await Loop( try LoopImage(data: data) ) { EmptyView() }
            
            print("HQ Loop View created")
        } catch {
            print("Error when loading HQ image" + error.localizedDescription)
        }
    }
}

struct HQView_Previews: PreviewProvider {
    static var previews: some View {
        HQView(urlString: "https://media2.giphy.com/media/nDSlfqf0gn5g4/giphy.webp?cid=92313d12ttm0chwtqkhy9c4r65n5wwydt4wicepaxuxvi068&rid=giphy.webp&ct=g")
    }
}
