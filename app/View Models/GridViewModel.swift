//
//  GridViewModel.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 01/06/2022.
//

import Foundation


@MainActor class GridViewModel: ObservableObject {
    
    @Published private(set) var isLoading: Bool = false
    
    @Published private(set) var gifItems = [GifData]()
    
    @Published var selectedGif: GifData?
    
    private enum TaskState {
        case free
        case inProgress(Task<Void, Error>?)
    }
    
    private var taskState: TaskState = .free {
        didSet {
            switch taskState {
            case .free:
                isLoading = false
            case .inProgress:
                isLoading = true
            }
        }
    }
    
    private let limit = 15 // maximum number of objects to return in API Response
    private let maxDownloadsPerQuery = 100 // prevent requesting too many Gifs with a beta API key
    
    private var offset = 0 // Specifies the starting position of the results. (pagination)
    private var canLoadMorePages = true // defined by Pagination object from the API Response

    var allowLoadingMoreContent: Bool {
        canLoadMorePages && offset < maxDownloadsPerQuery
    }
    
    private(set) var endpoint = Endpoint.trending(limitNbOfResults: 5, fromOffset: 0)
    
    init() {
        updateWith("")
    }
    
    func updateWith( _ newQuery: String) {
        print("Updating GridViewModel with new query: \(newQuery.isEmpty ? "empty > Trending GIFs" : newQuery)")
        
        switch taskState {
        case .free:
            taskState = .inProgress(nil) // a new task for a new query is gonna happen, prevent any updating of the grid with current query
        case .inProgress(let task):
            task?.cancel()
        }
        
        offset = 0
        canLoadMorePages = true
        
        if newQuery.isEmpty {
            endpoint = Endpoint.trending(limitNbOfResults: limit, fromOffset: 0)
        } else {
            endpoint = Endpoint.search(matching: newQuery, limitNbOfResults: limit, fromOffset: 0)
        }
        
        updateContent(replaceCurrentGifs: true)
    }
    
    private func freeTaskState() {
        taskState = .free
    }
    
    private func updateContent(replaceCurrentGifs: Bool = false) {
        
        taskState = TaskState.inProgress( Task {
            defer { Task { await freeTaskState() } } // make sure the task state is toggled back to free before we exit the scope, whatever happens during the Task
            
            guard allowLoadingMoreContent else {
                print("Not allowed to load more content")
                return
            }
            
            guard let url = endpoint.url else {
                print("Cannot update content: invalid URL")
                return
            }
            
            // Get data about our query:
            guard let apiResponse = await loadApiResponse(for: url) else {
                print("Can't get any anwser from API Endpoint")
                return
            }
            
            try Task.checkCancellation()
            
            // Update the pagination data:
            canLoadMorePages = apiResponse.pagination.totalCount > apiResponse.pagination.count + apiResponse.pagination.offset
            offset += apiResponse.pagination.count
            updateEndpoint(with: offset)
            
            // Fetch GIFs preview
            guard let newGifs = await loadGifsData(forGifsObjects: apiResponse.data) else {
                // Avoid displaying an empty grid when a new search return no result or if no network
                print("We were not able to fetch any Gifs ImageData from the network")
                return
            }
            
            try Task.checkCancellation()
            
            // Replace or Add to current displayed GIFs:
            if replaceCurrentGifs {
                gifItems = newGifs
            } else {
                gifItems.append(contentsOf: newGifs)
            }
            
            taskState = .free
            
        })
    }
    
    private func loadApiResponse(for url: URL) async -> ApiResponse?  {
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            try? Task.checkCancellation()
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return nil
            }
            
            let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
            
            return decodedResponse
            
        } catch  {
            print("Error while requesting API response: " + error.localizedDescription)
            return nil
        }
    }
    
    private func updateEndpoint(with offset: Int) {
        if endpoint.query.isEmpty {
            endpoint = Endpoint.trending(limitNbOfResults: limit, fromOffset: offset)
        } else {
            endpoint = Endpoint.search(matching: endpoint.query, limitNbOfResults: limit, fromOffset: offset)
        }
    }
    
    private func loadGifsData(forGifsObjects gifs: [GifObject]) async -> [GifData]? {
        
        return try? await withThrowingTaskGroup(of: GifData?.self) { group -> [GifData] in
            for gif in gifs {
                group.addTask{
                    let gifData = await GifDataLoader().loadGifData(for: gif)
                    return gifData
                }
            }
            
            var gifsData = [GifData]()
            
            for try await gifData in group {
                if let gifData = gifData {
                    gifsData.append(gifData)
                }
            }
            
            return gifsData
        }
    }

    func loadMoreContentIfNeeded(currentItem item: GifData? = nil) {
        
        guard let item = item else {
            switch taskState {
            case .free:
                updateContent()
            default:
                print("Already a task in progress, we won't request more content")
            }
            return
        }

        let thresholdIndex = gifItems.index(gifItems.endIndex, offsetBy: -1)
        
        if gifItems.firstIndex(where: { $0 == item }) == thresholdIndex {
            print("We decided to load more content!")
            
            switch taskState {
            case .free:
                updateContent()
            default:
                print("Already a task in progress, we won't request more content")
            }
        }
    }
}
