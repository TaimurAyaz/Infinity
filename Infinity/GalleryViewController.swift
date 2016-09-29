//
//  GalleryViewController.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import Alamofire


/// The view controller responsible for showing the gallery view
class GalleryViewController: UIViewController {
    
    // The collection view delegate and datasource.
    private(set) var manager: CollectionManager?
    
    // The collection view pagination controller.
    private(set) var paginationManager: PaginationManager?
    
    // The current displayed page from the backend.
    private(set) var currentPage: Int = 0
    
    // The collection view.
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    // The transitioning delegate for previewing the photo
    lazy private var photoTransitioningDelegate: PhotoTransitioningDelegate = PhotoTransitioningDelegate(photoPresenting: self)
    
    // The indexpath current presented photo. Takes into account and scrolling that might occur when proviewing a photo. 
    // The indexpath should map an indexPath on this controller since we are using a shared datasource.
    private var currentPresentedPhotoIndexPath: NSIndexPath = NSIndexPath()
}


// MARK:- View Lifecycle
extension GalleryViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // Setup views and managers, and load the first page.
    private func setup() {
        manager = CollectionManager(collectionView: collectionView)
        paginationManager = PaginationManager(collectionView: collectionView, direction: .vertical)
        paginationManager?.delegate = self
        
        view.addSubview(collectionView)
        
        setupConstraints()
        
        reload(currentPage + 1)
    }
    
    // setup collection view constraints
    private func setupConstraints() {
        let views: [String : AnyObject] = ["collectionView" : collectionView]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    // The grid layout engine expects the collection view to set appropriate insets.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? GalleryLayout else { return }
        collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length + layout.interItemSpacing,
                                                       layout.interItemSpacing,
                                                       layout.interItemSpacing,
                                                       layout.interItemSpacing)
        collectionView.scrollIndicatorInsets.top(collectionView.contentInset.top)
    }
    
    // Relayout the collection view when the orientation changes.
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        manager?.reload(size)
    }
}


// MARK:- Reloading
extension GalleryViewController {
    
    
    /// Reloads a given page from the backend and automatically updates the collectionView. 
    /// Optionally provides a completion block, informing whether new items were obtained or not.
    ///
    /// - parameter forPage:    The page to reload.
    /// - parameter completion: Optional completion block.
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
    
    // When a cell is selected, we want to display the photo previewing controller. 
    // We also set the `currentPresentedPhotoIndexPath` to the selected cell's indexPath
    func didSelectPhoto(atIndexPath indexPath: NSIndexPath) {
        guard let manager = manager else { return }
        currentPresentedPhotoIndexPath = indexPath
        let photoViewController = PhotoViewController(parentManager: manager, parentPaginationManagerDelegate: paginationManager?.delegate, initialIndex: indexPath)
        photoViewController.parentUpdating = self
        photoViewController.modalPresentationStyle = .Custom
        photoViewController.transitioningDelegate = photoTransitioningDelegate
        presentViewController(photoViewController, animated: true, completion: nil)
    }
}


// MARK:- PhotoPresenting
extension GalleryViewController: PhotoPresenting {
   
    // We pass in the `Photo` object associated with the `currentPresentedPhotoIndexPath`. 
    // So that the presentation controller can set the transition imageView's image.
    var photoForPresentedItem: Photo? {
        return manager?.items[currentPresentedPhotoIndexPath.item]
    }
    
    // We pass in the frame of the cell to facilitate the image transition.
    var frameForPresentedItem: CGRect {
        if let cell = collectionView.cellForItemAtIndexPath(currentPresentedPhotoIndexPath) {
            let frame = collectionView.convertRect(cell.frame, toView: self.collectionView.superview)
            return frame
        }
        return CGRectZero
    }
    
    // We require the following state methods to control the cell's visibility. 
    // This is done to give the appearance of the image popping into fullscreen.
    
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
    
    // Convenience method to set cell visibility
    private func setVisibilityForImageInCell(atIndexPath indexPath: NSIndexPath, isHidded: Bool) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageContaining {
            cell.imageView.hidden = isHidded
        }
    }
}


// MARK:- PhotoViewControllerParentUpdating
extension GalleryViewController: PhotoViewControllerParentUpdating {
    
    // We set the `currentPresentedPhotoIndexPath` based on the current scroll position on the prevewing controller.
    func photoViewController(photoViewController: PhotoViewController, didScrollToItemAtIndex index: Int) {
        currentPresentedPhotoIndexPath = NSIndexPath(forItem: index, inSection: 0)
    }
    
    // We set the `currentPresentedPhotoIndexPath` based on the last visible index on the previewing controller.
    // We scroll our collectionView to this indexPath to ensure the dismissal animation feels natural as the image shrinks to the cell.
    func photoViewController(photoViewController: PhotoViewController, willDismissFromItemAtIndex index: Int) {
        currentPresentedPhotoIndexPath = NSIndexPath(forItem: index, inSection: 0)
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
    }
}


// MARK:- PaginationManagerDelegate
extension GalleryViewController: PaginationManagerDelegate {
    
    // The pagination manager tells us when we exceed the given threshold. We then try to reload new items and inform the pagination manager
    // to continue once we receive items from the backend.
    func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock) {
        reload(currentPage + 1) { (newItemsAvailable) in
            reset(shouldReset: newItemsAvailable)
        }
    }
}
