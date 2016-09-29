//
//  PhotoCellSelecting.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation

/// A protocol providing selection methods for acting on cell selection.
@objc protocol PhotoCellSelecting {
    
    
    /// Informs the conforming object when the cell is selected.
    ///
    /// - parameter indexPath: The indexPath of the selected cell.
    func didSelectPhoto(atIndexPath indexPath: NSIndexPath)
}
