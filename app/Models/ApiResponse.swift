//
//  ApiResponse.swift
//  GiphyAPIdemo
//
//  Created by RqwerKnot on 30/05/2022.
//

import Foundation


struct ApiResponse: Decodable {
    let data: [GifObject]
    let pagination: PaginationObject
    let meta: MetaObject
}

struct GifObject: Decodable, Identifiable {
    let type: String
    let id: String
    let username: String
    let images: ImagesObject
    
    struct ImagesObject: Decodable {
        let fixedWidthSmall: RenditionObject
        let downsized: RenditionObject
        
        enum CodingKeys: String, CodingKey {
            case downsized
            case fixedWidthSmall = "fixed_width_small"
        }
    }
    
    struct RenditionObject: Decodable {
        let url: String
        let width: String
        let height: String
        let mp4: String?
        let webp: String?
    }
}

struct PaginationObject: Decodable {
    let count: Int
    let totalCount: Int
    let offset: Int
    
    enum CodingKeys: String, CodingKey {
        case count, offset
        case totalCount = "total_count"
    }
}

struct MetaObject: Decodable {
    let msg: String
    let status: Int
    let responseId: String
    
    enum CodingKeys: String, CodingKey {
        case msg, status
        case responseId = "response_id"
    }
}
