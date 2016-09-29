//
//  ImageContaining.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-27.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

/// A protocol defining the requirements for an object to contain an image.
protocol ImageContaining {
    var imageView: UIImageView { get set }
}
