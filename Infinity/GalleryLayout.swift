//
//  GalleryLayout.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

/// The grid layout engine. Based off `UICollectionViewFlowLayout` for convenience.
class GalleryLayout: UICollectionViewFlowLayout {
    
    // The interItem spacing for the layout.
    private(set) var interItemSpacing: CGFloat = 2
    
    // The maximum row height.
    private(set) var maximumRowHeight: CGFloat = 200
    
    // An array of computed item sizes.
    private(set) var itemSizes: [CGSize] = []
    
    
    /// Convenience initializer for the `GalleryLayout`.
    ///
    /// - parameter maximumRowHeight: The maximum row height.
    /// - parameter interItemSpacing: The interItem spacing for the layout.
    ///
    /// - returns: A newly created `GalleryLayout` object.
    convenience init(maximumRowHeight: CGFloat, interItemSpacing: CGFloat) {
        self.init()
        self.maximumRowHeight = maximumRowHeight
        self.interItemSpacing = interItemSpacing
        setup()
    }
    
    // Make sure we set the section insets to zero since, we configure the layout by the content insets of the collectionview and the interItem spacing.
    private func setup() {
        sectionInset = UIEdgeInsetsZero
    }
    
    
    /// Layout invalidation/preparation method.
    ///
    /// - parameter withItemSizes: The original image sizes.
    /// - parameter targetSize:    The size of the container. Pass in nil to use the collectionView's size. 
    ///                            Useful when the target size of the collection view is known before hand.
    func prepareLayout(withItemSizes: [CGSize], andContainerSize  containerSize: CGSize? = nil) {
        guard let collectionView = collectionView else { return }
        invalidateLayout()
        generateLayout(withItemSizes, containerSize: containerSize ?? collectionView.bounds.size)
    }
    
    // Private function to convenience the above.
    private func generateLayout(itemSizes: [CGSize], containerSize: CGSize) {
        guard let collectionView = collectionView else { return }
        let maxWidth = containerSize.width - collectionView.contentInset.left - collectionView.contentInset.right
        self.itemSizes = itemSizes.relativeSizes(forMaxContainerWidth: maxWidth, maxItemHeight: maximumRowHeight, spacing: interItemSpacing)
    }
    
    
    /// Method to get the size of an item at a given indexPath.
    ///
    /// - parameter indexPath: The indexPAth of the item.
    ///
    /// - returns: The size of the item at the given indexPath or zero size if the indexPath is invalid.
    func size(forItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if itemSizes.count > indexPath.row {
            return itemSizes[indexPath.row]
        }
        return CGSizeZero
    }
}


extension GalleryLayout {
    
    // A convenience method to generate sizes with a given array of `Photo` objects.
    func prepareLayout(withItems items: [Photo], andContainerSize containerSize: CGSize? = nil) {
        var sizes: [CGSize] = []
        
        if PhotoSizeManager.shared.currentSize == .uncropped {
            sizes = items.map({ $0.size })
        } else {
            let dimension: CGFloat = CGFloat(PhotoSizeManager.shared.currentSize.sizeIdForVariant(.normal))
            for _ in 0..<items.count {
                sizes.append(CGSizeMake(dimension, dimension))
            }
        }
        
        prepareLayout(sizes, andContainerSize: containerSize)
    }
}


/// The main logic of the layout engine.
extension CollectionType where Generator.Element == CGSize {
    
    
    /// Sizes based on the aspect ratio, constraint to the given width and maximum item height.
    ///
    /// - parameter maxContainerWidth:  The maximum container width.
    /// - parameter maxItemHeight: The maximum container height.
    /// - parameter spacing:   The spacing for the items.
    ///
    /// - returns: An array of normalized sizes.
    func relativeSizes(forMaxContainerWidth maxContainerWidth: CGFloat, maxItemHeight: CGFloat, spacing: CGFloat) -> [CGSize] {
        
        var returnValue: [CGSize] = []
        
        var currentRow: [CGSize] = []
        
        forEach {
            
            var newRow: [CGSize] = currentRow
            newRow.append($0)
            
            // Get the remaining width of the row after removing accumulated spacing
            let remainingWidthForRow =  maxContainerWidth - CGFloat(newRow.count - 1) * spacing
            
            // What should be the new height given the new remaining width
            let height = newRow.heightWhenConstraintToWidth(remainingWidthForRow)
            
            // if height is less than or equal to the max height, add it to the row and move to next row
            if height <= maxItemHeight {
                
                let adjustedSizes = newRow.constraintToHeight(0.999 * height)
                
                returnValue.appendContentsOf(adjustedSizes)
                currentRow.removeAll()
            } else {
                // If the height is greater than the maxHeight, keep adding to current row till we get a small enough height
                currentRow = newRow
            }
        }
        
        // Handle the case when the last iteration of the `forEach` results in `currentRow` not being empty.
        let adjustedSizes = currentRow.constraintToHeight(maxItemHeight)
        returnValue.appendContentsOf(adjustedSizes)
        
        return returnValue
    }
    
    
    
    /// Constraints the height of each of the `CGSize` to the given height.
    ///
    /// - parameter height: The height to constraint to.
    ///
    /// - returns: An array of height constraint CGSize
    func constraintToHeight(height: CGFloat) -> [CGSize] {
        var adjusted: [CGSize] = []
        forEach({
            let adjustedWidth = ( $0.width * height / $0.height )
            adjusted.append(CGSizeMake(adjustedWidth, height))
        })
        return adjusted
    }
    
    
    /// The height when constraint to a given width. Takes into account the aspect ratio's of the sizes.
    ///
    /// - parameter width: The constraint width.
    ///
    /// - returns: The new height.
    func heightWhenConstraintToWidth(width: CGFloat) -> CGFloat {
        let aspect = reduce(0, combine: {
            $0 + ($1.width / $1.height)
        })
        return width/aspect
    }
}
