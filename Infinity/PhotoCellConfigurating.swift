//
//  PhotoCellConfigurating.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

/// A protocol defining a convenience method to configure a cell with a Photo
protocol PhotoCellConfigurating {
    
    /// Configures the object with a photo
    ///
    /// - parameter photo:         The `Photo` object.
    /// - parameter sizeId:        The sizeId of the image
    /// - parameter fadeFromBlank: Should trainsition from a blank image?
    func configure(withPhoto photo: Photo, sizeId: Int, fadeFromBlank: Bool)
}
