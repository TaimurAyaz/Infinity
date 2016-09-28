//
//  PhotoViewControllerParentUpdating.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation

protocol PhotoViewControllerParentUpdating: class {
    func photoViewController(photoViewController: PhotoViewController, didScrollToItemAtIndex index: Int)
    func photoViewController(photoViewController: PhotoViewController, willDismissFromItemAtIndex index: Int)
}
