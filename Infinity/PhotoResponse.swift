//
//  PhotoResult.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import ObjectMapper

/// A model defining the response for the photo endpoint request
class PhotoResponse: Mappable {
    
    // The photos returned by the enpoint for the specified parameters.
    var photos: [Photo]?
    
    // The current page of the response.
    var currentPage: Int?
    
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        photos <- map["photos"]
        currentPage <- map["current_page"]
    }
}
