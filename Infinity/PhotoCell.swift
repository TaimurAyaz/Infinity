//
//  PhotoCell.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import AlamofireImage

/// The cell for `PhotoViewController`
class PhotoCell: GalleryCell {
    
    // Make sure we fade in from the image already shown in the cell. Use a blank image otherwise.
    override func configure(withPhoto photo: Photo, sizeId: Int, fadeFromBlank: Bool) {
        let url = photo.imageURLFor(sizeId: sizeId)
        imageView.af_setImageWithURL(url, placeholderImage: fadeFromBlank ? UIImage() : imageView.image, imageTransition: .CrossDissolve(0.3))
    }
}
