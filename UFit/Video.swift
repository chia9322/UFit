//
//  Video.swift
//  UFit
//
//  Created by Chia on 2021/12/21.
//

import Foundation

struct Video {
    let title: String
    let thumbnailUrl: URL
    let videoId: String
    var isFavorite: Bool = false
    
    var category: Category?
    var difficultLevel: Int?
    var workoutDates: [Date] = []
}


enum Category {
    case yoga, training
}
