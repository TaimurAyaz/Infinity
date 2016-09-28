//
//  PhotoCellConfigurating.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation

protocol PhotoCellConfigurating {
    func configure(withPhoto photo: Photo, sizeId: Int, fadeFromBlank: Bool)
}
