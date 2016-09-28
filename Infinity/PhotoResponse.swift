//
//  PhotoResult.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import ObjectMapper

class PhotoResponse: Mappable {
    
    var photos: [Photo]?
    var totalItems: Int?
    var currentPage: Int?
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        photos <- map["photos"]
        totalItems <- map["total_items"]
        currentPage <- map["current_page"]
    }
}
