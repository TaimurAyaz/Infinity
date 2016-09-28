//
//  PhotoPresenting.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoPresenting: class {
        
    var photoForPresentedItem: Photo? { get }
    var frameForPresentedItem: CGRect { get }
    
    func willPresentPhoto()
    func didPresentPhoto()
    
    func willDismissPhoto()
    func didDismissPhoto()
}
