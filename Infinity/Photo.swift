//
//  Photo.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import ObjectMapper


// Alias for a dictionary containing string urls for images, keyed by their sizeIds.
typealias ImageSizeDictionary = [Int : String]

/// A model defining the photo object.
class Photo: Mappable {
    
    // The original width of the photo.
    private(set) var width: Int?
    
    // The original height of the photo.
    private(set) var height: Int?
    
    // The original size of the photo.
    var size: CGSize {
        guard let width = width, height = height else { return CGSizeZero }
        return CGSizeMake(CGFloat(width), CGFloat(height))
    }
    
    // The images associated with the photo.
    private(set) var images: [ImageProperty]? {
        didSet {
            guard let images = images else { return }
            imageSizeDictionary = images.toDictionary({
                guard let key = $0.sizeId, url = $0.url else { return nil }
                return (key, url)
            })
        }
    }
    
    // A dictionary containing string urls for images, keyed by their sizeIds.
    private(set) var imageSizeDictionary: ImageSizeDictionary = [:]
    
    // Convenience method to get url for a given sizeId. If there is no value url, an empty `NSURL` object is returned.
    func imageURLFor(sizeId sizeId: Int) -> NSURL {
        guard let link = imageSizeDictionary[sizeId], url = NSURL(string: link) else { return NSURL() }
        return url
    }
    
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        width <- map["width"]
        height <- map["height"]
        images <- map["images"]
    }
}
