//
//  EndPoint.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation

/// An enum defining an endpoint. Created to possibly enhance with more endpoints in the future.
enum EndPoint {
    
    // The `photos` endpoint. Requires an array of sizeIds and the page number.
    case photos(sizeIds: [Int], pageNumber: Int)
    
    // Returns the key endpoint string.
    func parameter() -> String {
        switch self {
        case .photos:
            return "photos"
        }
    }
}

/// an enum defining the parameters for the endpoint.
enum EndPointParameters: String {
    case consumerKey = "consumer_key"
    case imageSize = "image_size"
    case pageNumber = "page"
    case numberOfItems = "rpp"
}
