//
//  PaginationManager.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-27.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

// Alias for the pagination manager reset block.
typealias PaginationManagerResetBlock = (shouldReset: Bool) -> ()

/// The pagination manager delegate.
protocol PaginationManagerDelegate: class {
    
    
    /// Tells the conforming object that the pagination manager has exceeded the given threshold.
    ///
    /// - parameter manager:   The pagination manager.
    /// - parameter threshold: The threshold that was exceeded.
    /// - parameter reset:     The reset block for the pagination manager. Used to tell the pagination manager to reset its state.
    func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock)
}

/// Private enum defining the possible states of the pagination manager.
private enum PaginationManagerState {
    case normal
    case exceeded
}

/// The scroll direction for the pagination manager
enum PaginationManagerDirection {
    case horizontal
    case vertical
}

class PaginationManager: NSObject {
    
    // Weak reference to the pagination manager delegate
    weak var delegate: PaginationManagerDelegate?
    
    // The percentage scrolled by the user. The main logic for the pagination manager resides in the `didSet` block.
    private(set) var percentageScrolled: CGFloat = 0 {
        didSet {
            if percentageScrolled > thresholdPercentage && state != .exceeded {
                state = .exceeded
                delegate?.paginationManagerDidExceedThreshold(self, threshold: thresholdPercentage, reset: { [weak self] (shouldReset) in
                    if shouldReset {
                        self?.state = .normal
                    }
                })
            }
        }
    }
    // The default threshold percentage for the pagination manager.
    var thresholdPercentage: CGFloat = 0.6
    
    // The default direction for the pagination manager. Overridable in the initializer.
    private(set) var direction: PaginationManagerDirection = .vertical

    // The default state of the pagination manager.
    private var state: PaginationManagerState = .normal
    
    // Weak reference to the collection view.
    private weak var collectionView: UICollectionView?
    
    // Weak reference to the original delegate of the collection view.
    private weak var originalDelegate: UICollectionViewDelegate?

    
    /// Designated initializer for the pagination manager.
    ///
    /// - parameter collectionView: The collection view to be associated with the apgination manager
    /// - parameter direction:      The scroll direction of the collection view.
    ///
    /// - returns: A newly created pagnination manager.
    init(collectionView: UICollectionView, direction: PaginationManagerDirection) {
        self.collectionView = collectionView
        self.originalDelegate = collectionView.delegate
        self.direction = direction
        super.init()
        collectionView.delegate = self
    }
}

extension PaginationManager: UICollectionViewDelegate {
    
    // Hook into the scrollview delegate method to compute the percentage scrolled.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidScroll?(scrollView)
        
        guard state == .normal && collectionView?.contentSize != CGSizeZero else { return }
        
        let scrollViewContentInsets = scrollView.contentInset

        var scrollViewKeyOffset = scrollView.contentOffset.y
        var scrollViewKeyDimension = scrollView.frame.size.height
        var scrollViewContentKeyDimension = scrollView.contentSize.height
        var normalizedOffset = scrollViewKeyOffset + scrollViewContentInsets.top
        var normalizedSize = scrollViewContentKeyDimension - (scrollViewKeyDimension - scrollViewContentInsets.top - scrollViewContentInsets.bottom)
        
        if direction == .horizontal {
            scrollViewKeyOffset = scrollView.contentOffset.x
            scrollViewKeyDimension = scrollView.frame.size.width
            scrollViewContentKeyDimension = scrollView.contentSize.width
            normalizedOffset = scrollViewKeyOffset + scrollViewContentInsets.left
            normalizedSize = scrollViewContentKeyDimension - (scrollViewKeyDimension - scrollViewContentInsets.left - scrollViewContentInsets.right)
        }
        
        if normalizedSize > 0 && normalizedOffset >= 0 {
            let percentageScrolled = normalizedOffset / normalizedSize
            self.percentageScrolled = percentageScrolled
        }
    }
    
    // Pass unsed delegate methods back to the original delegate.
    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        if let delegateResponds = self.originalDelegate?.respondsToSelector(aSelector) where delegateResponds == true {
            return true
        }
        return super.respondsToSelector(aSelector)
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return self.originalDelegate
    }
}
