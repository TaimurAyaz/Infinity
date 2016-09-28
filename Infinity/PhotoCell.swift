//
//  PhotoCell.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotoCell: GalleryCell {

    override func configure(withPhoto photo: Photo, sizeId: Int, fadeFromBlank: Bool) {
        let imageLink = photo.imageLinkFor(size: sizeId)
        if let url = NSURL(string: imageLink.url) {
            imageView.af_setImageWithURL(url, placeholderImage: fadeFromBlank ? UIImage() : imageView.image, imageTransition: .CrossDissolve(0.3))
        }
    }
}
