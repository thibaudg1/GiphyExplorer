//
//  AnimatedImage.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 31/05/2022.
//

import SwiftUI
import Looping
import LoopingWebP

struct AnimatedImage: View {
    
    let imageData: Data
    
    var loopImage: LoopImage? {
        try? LoopImage(data: imageData)
    }
    
    var body: some View {
        ZStack {
            ProgressView()
            
            if let loopImage = loopImage {
                Loop(loopImage) {
                    EmptyView()
                }
                .resizable()
                .scaledToFill()
            }
        }
    }
}

//struct AnimatedImage_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimatedImage()
//    }
//}
