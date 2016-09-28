//
//  GalleryViewController.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import Alamofire

class GalleryViewController: UIViewController {
    
    private(set) var manager: CollectionManager?
    private(set) var paginationManager: PaginationManager?
    
    private(set) var currentPage: Int = 0
    
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    private let statusBarView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var photoTransitioningDelegate: PhotoTransitioningDelegate = PhotoTransitioningDelegate(photoPresenting: self)
    private var currentPresentedPhotoIndexPath: NSIndexPath = NSIndexPath()
}


// MARK:- View Lifecycle
extension GalleryViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        manager = CollectionManager(collectionView: collectionView)
        paginationManager = PaginationManager(collectionView: collectionView, direction: .vertical)
        paginationManager?.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(statusBarView)
        
        setupConstraints()
        
        reload(currentPage + 1)
    }
    
    private func setupConstraints() {
        let views: [String : AnyObject] = ["statusBarView" : statusBarView, "collectionView" : collectionView]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[statusBarView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[statusBarView]", options: [], metrics: nil, views: views)
        constraints += [NSLayoutConstraint(item: statusBarView, attribute: .Bottom, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0)]
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? GalleryLayout else { return }
        collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length + layout.interItemSpacing,
                                                       layout.interItemSpacing,
                                                       layout.interItemSpacing,
                                                       layout.interItemSpacing)
        collectionView.scrollIndicatorInsets.top(collectionView.contentInset.top)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        manager?.reload(size)
    }
}


// MARK:- Reloading
extension GalleryViewController {
    
    func reload(forPage: Int, completion: ((newItemsAvailable: Bool) -> ())? = nil) {
        DataKit.get(.photos(sizeIds: PhotoSizeManager.shared.currentSize.allVariantSizeIds(), pageNumber: forPage)) { [weak self] (photos, currentPage) in
            if currentPage == self?.currentPage {
                completion?(newItemsAvailable: false)
            } else {
                self?.manager?.items.appendContentsOf(photos)
                self?.currentPage = currentPage
                completion?(newItemsAvailable: true)
            }
        }
    }
}


// MARK:- PhotoCellSelecting
extension GalleryViewController: PhotoCellSelecting {
    func didSelectPhoto(atIndexPath indexPath: NSIndexPath) {
        guard let manager = manager else { return }
        currentPresentedPhotoIndexPath = indexPath
        let photoViewController = PhotoViewController(parentManager: manager, parentPaginationManagerDelegate: paginationManager?.delegate, initialIndex: indexPath)
        photoViewController.parentUpdating = self
        photoViewController.modalPresentationStyle = .Custom
        photoViewController.transitioningDelegate = photoTransitioningDelegate
        
        if let navigationController = navigationController {
            navigationController.presentViewController(photoViewController, animated: true, completion: nil)
        } else {
            presentViewController(photoViewController, animated: true, completion: nil)
        }
    }
}


// MARK:- PhotoPresenting
extension GalleryViewController: PhotoPresenting {
   
    var photoForPresentedItem: Photo? {
        return manager?.items[currentPresentedPhotoIndexPath.item]
    }
    
    var frameForPresentedItem: CGRect {
        if let cell = collectionView.cellForItemAtIndexPath(currentPresentedPhotoIndexPath) {
            let frame = collectionView.convertRect(cell.frame, toView: self.collectionView.superview)
            return frame
        }
        return CGRectZero
    }
    
    func willPresentPhoto() {
        setVisibilityForImageInCell(atIndexPath: currentPresentedPhotoIndexPath, isHidded: true)
    }
    
    func didPresentPhoto() {
        setVisibilityForImageInCell(atIndexPath: currentPresentedPhotoIndexPath, isHidded: false)
    }
    
    func willDismissPhoto() {
        setVisibilityForImageInCell(atIndexPath: currentPresentedPhotoIndexPath, isHidded: true)
    }
    
    func didDismissPhoto() {
        setVisibilityForImageInCell(atIndexPath: currentPresentedPhotoIndexPath, isHidded: false)
    }
    
    private func setVisibilityForImageInCell(atIndexPath indexPath: NSIndexPath, isHidded: Bool) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageContaining {
            cell.imageView.hidden = isHidded
        }
    }
}


// MARK:- PhotoViewControllerParentUpdating
extension GalleryViewController: PhotoViewControllerParentUpdating {
    func photoViewController(photoViewController: PhotoViewController, didScrollToItemAtIndex index: Int) {
        currentPresentedPhotoIndexPath = NSIndexPath(forItem: index, inSection: 0)
    }
    
    func photoViewController(photoViewController: PhotoViewController, willDismissFromItemAtIndex index: Int) {
        currentPresentedPhotoIndexPath = NSIndexPath(forItem: index, inSection: 0)
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
    }
}


// MARK:- PaginationManagerDelegate
extension GalleryViewController: PaginationManagerDelegate {
    func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock) {
        reload(currentPage + 1) { (newItemsAvailable) in
            reset(shouldReset: newItemsAvailable)
        }
    }
}
