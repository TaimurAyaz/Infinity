//
//  GalleryCell.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import AlamofireImage

class GalleryCell: UICollectionViewCell, PhotoCellConfigurating, ImageContaining {
    
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
    
    func configure(withPhoto photo: Photo, sizeId: Int, fadeFromBlank: Bool) {
        let imageLink = photo.imageLinkFor(size: sizeId)
        if let url = NSURL(string: imageLink.url) {
            imageView.af_setImageWithURL(url, placeholderImage:UIImage(), imageTransition: .CrossDissolve(0.3))
        }
    }
}
