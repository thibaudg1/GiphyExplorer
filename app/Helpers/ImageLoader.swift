//
//  ActorImageLoader.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 03/06/2022.
//

import Foundation

actor ImageLoader {
    typealias ImageData = Data
    
    // ImageData memory
    private var images: [URLRequest: LoaderStatus] = [:]

    // fetch image by URL (convenience API)
    public func fetch(_ url: URL) async throws -> ImageData {
        let request = URLRequest(url: url)
        return try await fetch(request)
    }
    
    // fetch image by URLRequest
    public func fetch(_ urlRequest: URLRequest) async throws -> ImageData {
        // Check if we have the requested ImageData in memory:
        if let status = images[urlRequest] {
                switch status {
                case .fetched(let imageData):
                    //print("ImageData found in memory for \(urlRequest)")
                    return imageData
                case .inProgress(let task):
                    print("Request in-flight for: \(urlRequest)")
                    return try await task.value
                }
            }

        // Check if we have the requested ImageData on disk:
        if let imageData = self.imageFromFileSystem(for: urlRequest) {
            images[urlRequest] = .fetched(imageData)
            return imageData
        }
        
        // Otherwise kick off a network request:
        let task: Task<ImageData, Error> = Task {
            let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
            
            // Store persistently imageData:
            self.persistImage(imageData, for: urlRequest)

            return imageData
        }
        
        // Update the ImageData memory:
        images[urlRequest] = .inProgress(task)

        let imageData = try await task.value

        images[urlRequest] = .fetched(imageData)

        return imageData
    }
    
    // Write ImageData to disk
    private func persistImage(_ imageData: ImageData, for urlRequest: URLRequest) {
        guard let url = fileName(for: urlRequest) else {
            print("Unable to generate a local path for \(urlRequest)")
            return
        }
        
        do {
            try imageData.write(to: url, options: .atomic)
        } catch {
            print("Unable to persist image data")
        }
        
    }
    
    // Retrieve Imagedata from disk
    private func imageFromFileSystem(for urlRequest: URLRequest) -> ImageData? {
        guard let url = fileName(for: urlRequest) else {
            print("Unable to generate a local path for \(urlRequest)")
            return nil
        }
        
        do {
            let imageData = try Data(contentsOf: url)
            //print("We found image data on cache disk")
            return imageData
        } catch {
            return nil
        }
        
    }
    
    // Find a local file's URL for a URLRequest representing an network URL representing an ImageData source
    private func fileName(for urlRequest: URLRequest) -> URL? {
        guard let fileName = urlRequest.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                  return nil
              }

        return cachesDirectory.appendingPathComponent(fileName)
        //return documentsDirectory.appendingPathComponent(UUID().uuidString)
    }
    
    private enum LoaderStatus {
        case inProgress(Task<ImageData, Error>)
        case fetched(ImageData)
    }
}

extension ImageLoader {
    static let shared = ImageLoader()
}
