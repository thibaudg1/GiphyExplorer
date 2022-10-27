//
//  ImageLoader.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 01/06/2022.
//

import Foundation

class GifDataLoader {
    
    func loadGifData(for gif: GifObject) async -> GifData? {
        guard let urlString = gif.images.fixedWidthSmall.webp, let url = URL(string: urlString) else {
            print("There is no small webp animated image available for this Gif")
            return nil
        }
        
        do {
            let imageData = try await ImageLoader.shared.fetch(url)
            
            return GifData(preview: imageData, hqUrl: gif.images.downsized.url)
            
        } catch {
            print("Error while fetching imageData for gif# \(gif.id) - \(error.localizedDescription)")
            
            return nil
        }
    }
}
