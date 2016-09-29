//
//  GalleryCell.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import AlamofireImage

// The cell for `GalleryViewController`.
class GalleryCell: UICollectionViewCell, PhotoCellConfigurating, ImageContaining {
    
    // The image view for the cell.
    var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .ScaleAspectFit
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(imageView)
        let views = ["imageView" : imageView]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    // Make sure we always fade in from blank
    func configure(withPhoto photo: Photo, sizeId: Int, fadeFromBlank: Bool) {
        let url = photo.imageURLFor(sizeId: sizeId)
        imageView.af_setImageWithURL(url, placeholderImage:UIImage(), imageTransition: .CrossDissolve(0.3))
    }
}
