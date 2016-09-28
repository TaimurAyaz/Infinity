//
//  PhotoSizeManager.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation


enum PhotoSize {
    case cropped
    case uncropped
    
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
    
    func allVariantSizeIds() -> [Int] {
        return [sizeIdForVariant(.normal), sizeIdForVariant(.large)]
    }
}

enum PhotoSizeVariant {
    case normal
    case large
}


class PhotoSizeManager {
    
    static let shared: PhotoSizeManager = PhotoSizeManager()
    
    var currentSize: PhotoSize = .uncropped
}
