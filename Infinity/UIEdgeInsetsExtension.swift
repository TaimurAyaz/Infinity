//
//  UIEdgeInsetsExtension.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-29.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

/// A helper extension on `UIEdgeInsets`
extension UIEdgeInsets {
    
    
    /// `Mutating Function:` Sets the top inset to a new value, keeping other insets the same.
    ///
    /// - parameter newValue: The new top value.
    mutating func top(newValue: CGFloat) {
        self = UIEdgeInsetsMake(newValue, self.left, self.bottom, self.right)
    }
}
