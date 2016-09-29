//
//  PhotoSizeManager.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation

/// An enum that defines the possible image sizes.
enum PhotoSize {
    case cropped
    case uncropped
    
    
    /// Method to get the sizeId for the given `PhotoSizeVariant`
    ///
    /// - parameter variant: The photo size variant to get the sizeId for.
    ///
    /// - returns: An integer value representing the sizeId for the size.
    func sizeIdForVariant(variant: PhotoSizeVariant) -> Int {
        switch self {
        case .cropped:
            switch variant {
            case .normal:
                return 440
            case .large:
                return 6
            }
        case .uncropped:
            switch variant {
            case .normal:
                return 20
            case .large:
                return 6
            }
        }
    }
    
    
    /// Convenience method to get the all the sizeIds for a given size.
    func allVariantSizeIds() -> [Int] {
        return [sizeIdForVariant(.normal), sizeIdForVariant(.large)]
    }
}

/// An enum defining the possible size variations.
enum PhotoSizeVariant {
    case normal
    case large
}


/// A singleton that defines the current size.
class PhotoSizeManager {
    
    static let shared: PhotoSizeManager = PhotoSizeManager()
    
    // The current photo size.
    var currentSize: PhotoSize = .uncropped
}
