//
//  PhotoPresenting.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

// A protocol to define the parameters regarding presenting the `PhotoViewController`
protocol PhotoPresenting: class {
    
    // The photo associated with the item that was tapped in the gallery.
    var photoForPresentedItem: Photo? { get }
    
    // The frame for the tapped item in the galley.
    var frameForPresentedItem: CGRect { get }
    
    // Presentation state methods
    
    func willPresentPhoto()
    func didPresentPhoto()
    func willDismissPhoto()
    func didDismissPhoto()
}
