//
//  Endpoint.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 08/06/2022.
//

import Foundation


struct Endpoint {
    let path: String
    let query: String
    let queryItems: [URLQueryItem]
}

extension Endpoint {
    static let apiKey = "YOUR_API_KEY"
}

extension Endpoint {
    static func search(matching query: String, limitNbOfResults: Int, fromOffset offset: Int) -> Endpoint {
        return Endpoint(
            path: "/v1/gifs/search",
            query: query,
            queryItems: [
                URLQueryItem(name: "api_key", value: Endpoint.apiKey),
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: "\(limitNbOfResults)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        )
    }
    
    static func trending(limitNbOfResults: Int, fromOffset offset: Int) -> Endpoint {
        return Endpoint(
            path: "/v1/gifs/trending",
            query: "",
            queryItems: [
                URLQueryItem(name: "api_key", value: Endpoint.apiKey),
                URLQueryItem(name: "limit", value: "\(limitNbOfResults)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        )
    }
}

extension Endpoint {
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.giphy.com"
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}

