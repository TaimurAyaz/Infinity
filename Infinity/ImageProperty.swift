//
//  ImageProperty.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import ObjectMapper


/// A model containing the image properties
class ImageProperty: Mappable {
    
    // The url of the image
    private(set) var url: String?
    
    // The size id of the image
    private(set) var sizeId: Int?
    
    required init?(_ map: Map) { }
    
    func mapping(map: Map) {
        url <- map["https_url"]
        sizeId <- map["size"]
    }
}
