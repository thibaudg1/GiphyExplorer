//
//  GridView.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 01/06/2022.
//

import SwiftUI


struct GridView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass

    
    @ObservedObject var model: GridViewModel

    // Layout used for each column of LazyVGrid
    var columns: Int {
        switch sizeClass {
        case .regular:
            return 6
        default:
            return 3
        }
    }
    var layout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 4), count: columns)
    }
    
    var body: some View {
        GeometryReader { geoProxy in
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: layout, alignment: .center, spacing: 2) {
                    ForEach(model.gifItems) { item in
                        AnimatedImage(imageData: item.preview)
                            .frame(width: geoProxy.size.width / CGFloat(columns), height: geoProxy.size.width / CGFloat(columns))
                            .clipped()
                            .onTapGesture {
                                model.selectedGif = item
                            }
                            .onAppear {
                                model.loadMoreContentIfNeeded(currentItem: item)
                            }
                    }
                    
                    Group {
                        if model.isLoading {
                            ProgressView()
                        } else if model.allowLoadingMoreContent {
                            Button {
                                model.loadMoreContentIfNeeded()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                    .font(.largeTitle)
                            }
                        }
                    }
                    .frame(width: geoProxy.size.width / CGFloat(columns), height: geoProxy.size.width / CGFloat(columns))
                }
            }
        }
        .background(colorScheme == .light ? .white : .black)
        .sheet(item: $model.selectedGif) { gif in
            HQView(urlString: gif.hqUrl)
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(model: GridViewModel())
    }
}
