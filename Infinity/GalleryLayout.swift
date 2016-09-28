//
//  GalleryLayout.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

class GalleryLayout: UICollectionViewFlowLayout {
    
    private(set) var interItemSpacing: CGFloat = 2
    
    private(set) var maximumRowHeight: CGFloat = 200
    
    private(set) var itemSizes: [CGSize] = []
    
    convenience init(maximumRowHeight: CGFloat, interItemSpacing: CGFloat) {
        self.init()
        self.maximumRowHeight = maximumRowHeight
        self.interItemSpacing = interItemSpacing
        setup()
    }
    
    private func setup() {
        sectionInset = UIEdgeInsetsZero
    }
    
    func prepareLayout(withItemSizes: [CGSize], andTargetSize  targetSize: CGSize? = nil) {
        guard let collectionView = collectionView else { return }
        invalidateLayout()
        generateLayout(withItemSizes, targetSize: targetSize ?? collectionView.bounds.size)
    }
    
    private func generateLayout(itemSizes: [CGSize], targetSize: CGSize) {
        guard let collectionView = collectionView else { return }
        let maxWidth = targetSize.width - collectionView.contentInset.left - collectionView.contentInset.right
        self.itemSizes = itemSizes.relativeSizes(forMaxWidth: maxWidth, maxHeight: maximumRowHeight, viewHeight: collectionView.bounds.size.height, spacing: interItemSpacing)
    }
    
    func size(forItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if itemSizes.count > indexPath.row {
            return itemSizes[indexPath.row]
        }
        return CGSizeZero
    }
}


extension GalleryLayout {
    
    func prepareLayout(withItems items: [Photo], andTargetSize targetSize: CGSize? = nil) {
        var sizes: [CGSize] = []
        
        if PhotoSizeManager.shared.currentSize == .uncropped {
            sizes = items.map({ $0.size })
        } else {
            let dimension: CGFloat = CGFloat(PhotoSizeManager.shared.currentSize.sizeIdForVariant(.normal))
            for _ in 0..<items.count {
                sizes.append(CGSizeMake(dimension, dimension))
            }
        }
        
        prepareLayout(sizes, andTargetSize: targetSize)
    }
}


extension CollectionType where Generator.Element == CGSize {
    
    func relativeSizes(forMaxWidth maxWidth: CGFloat, maxHeight:CGFloat, viewHeight:CGFloat = 0 , spacing: CGFloat) -> [CGSize] {
        
        var returnValue: [CGSize] = []
        
        var currentRow: [CGSize] = []
        let threshold:CGFloat = maxHeight
        
        forEach {
            
            var newArray:[CGSize] = currentRow
            newArray.append($0)
            
            // get the remaining width of the row after removing accumulated spacing
            let remainingWidthForRow =  maxWidth - CGFloat(newArray.count - 1) * spacing
            
            // what should be the new height given the new remaining width
            let height = newArray.heightWhenConstraintToWidth(remainingWidthForRow)
            
            // if height is less than the max height, add it to the return and move to next row
            if height <= threshold {
                
                let adjustedSizes = newArray.constraintToHeight(0.999 * height)
                
                returnValue.appendContentsOf(adjustedSizes)
                currentRow.removeAll()
            } else {
                // keep adding to current row till we get a small enough height
                currentRow = newArray
            }
        }
        
        let adjustedSizes = currentRow.constraintToHeight(threshold)
        returnValue.appendContentsOf(adjustedSizes)
        
        return returnValue
    }
    
    
    func constraintToHeight(height: CGFloat) -> [CGSize] {
        var adjusted: [CGSize] = []
        forEach({
            let adjustedWidth = ( $0.width * height / $0.height )
            adjusted.append(CGSizeMake(adjustedWidth, height))
        })
        return adjusted
    }
    
    func heightWhenConstraintToWidth(width: CGFloat) -> CGFloat {
        let aspect = reduce(0, combine: {
            $0 + ($1.width / $1.height)
        })
        return width/aspect
    }
}


extension UIEdgeInsets {
    mutating func top(newValue: CGFloat) {
        self = UIEdgeInsetsMake(newValue, self.left, self.bottom, self.right)
    }
}
