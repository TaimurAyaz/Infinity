//
//  EndPoint.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation

enum EndPoint {
    case photos(sizeIds: [Int], pageNumber: Int)
    
    func parameter() -> String {
        switch self {
        case .photos:
            return "photos"
        }
    }
}

enum EndPointParameters: String {
    case consumerKey = "consumer_key"
    case imageSize = "image_size"
    case pageNumber = "page"
    case numberOfItems = "rpp"
}
