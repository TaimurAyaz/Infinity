//
//  Photo.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import ObjectMapper

typealias ImageLink = (url: String, format: String)
typealias ImageSizeDictionary = [Int : ImageLink]

class Photo: Mappable {
    
    var width: Int?
    
    var height: Int?
    
    var size: CGSize {
        guard let width = width, height = height else { return CGSizeZero }
        return CGSizeMake(CGFloat(width), CGFloat(height))
    }
    
    var images: [ImageProperty]? {
        didSet {
            guard let images = images else { return }
            imageSizeDictionary = images.toDictionary({
                guard let key = $0.size, url = $0.url, format = $0.format else { return nil }
                return (key, (url, format))
            })
        }
    }
    
    private(set) var imageSizeDictionary: ImageSizeDictionary = [:]
    
    func imageLinkFor(size size: Int) -> ImageLink {
        guard let link = imageSizeDictionary[size] else { return ("","") }
        return link
    }
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        width <- map["width"]
        height <- map["height"]
        images <- map["images"]
    }
}
