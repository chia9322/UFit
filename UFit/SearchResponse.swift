//
//  SearchResponse.swift
//  UFit
//
//  Created by Chia on 2021/12/21.
//

import Foundation


struct SearchResponse: Codable {
    let items: [Item]
    let nextPageToken: String
    
    struct Item: Codable {
        let snippet: Snippet

        struct Snippet: Codable {
            let title: String
            let thumbnails: Thumbnail
            let resourceId: ResourceId
            
            struct Thumbnail: Codable {
                let standard: ThumbnailImage
                let maxres: ThumbnailImage
                struct ThumbnailImage: Codable {
                    let url: URL
                }
            }
            
            struct ResourceId: Codable {
                let videoId: String
            }
        }
    }
}






