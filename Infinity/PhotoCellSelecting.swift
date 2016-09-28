//
//  PhotoCellSelecting.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation

@objc protocol PhotoCellSelecting {
    func didSelectPhoto(atIndexPath indexPath: NSIndexPath)
}
