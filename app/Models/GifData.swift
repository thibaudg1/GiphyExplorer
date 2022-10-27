//
//  SearchResults.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 31/05/2022.
//

import Foundation

struct GifData: Identifiable, Equatable {
    static func == (lhs: GifData, rhs: GifData) -> Bool {
        lhs.id == rhs.id
    }
    
    typealias ImageData = Data
    
    let id = UUID()
    let preview: ImageData
    let hqUrl: String
}
