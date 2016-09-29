//
//  PhotoViewControllerParentUpdating.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation

// Protocol to update the parent/presenter of the photo previewing controller
protocol PhotoViewControllerParentUpdating: class {
    
    // Informs when the `PhotoViewController` scrolls to an item.
    func photoViewController(photoViewController: PhotoViewController, didScrollToItemAtIndex index: Int)
    
    // Informs when the `PhotoViewController` is about to dismiss.
    func photoViewController(photoViewController: PhotoViewController, willDismissFromItemAtIndex index: Int)
}
