//
//  ImageProperty.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import ObjectMapper


class ImageProperty: Mappable {
    var url: String?
    var size: Int?
    var format: String?
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        url <- map["https_url"]
        size <- map["size"]
        format <- map["format"]
    }
}
