//
//  PaginationManager.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-27.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

typealias PaginationManagerResetBlock = (shouldReset: Bool) -> ()

protocol PaginationManagerDelegate: class {
    func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock)
}

private enum PaginationManagerState {
    case normal
    case exceeded
}

enum PaginationManagerDirection {
    case horizontal
    case vertical
}

class PaginationManager: NSObject {
    
    weak var delegate: PaginationManagerDelegate?
    
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
    var thresholdPercentage: CGFloat = 0.6
    private(set) var direction: PaginationManagerDirection = .vertical

    
    private var state: PaginationManagerState = .normal
    
    private weak var collectionView: UICollectionView?
    private weak var originalDelegate: UICollectionViewDelegate?

    init(collectionView: UICollectionView, direction: PaginationManagerDirection) {
        self.collectionView = collectionView
        self.originalDelegate = collectionView.delegate
        self.direction = direction
        super.init()
        collectionView.delegate = self
    }
}

extension PaginationManager: UICollectionViewDelegate {
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
