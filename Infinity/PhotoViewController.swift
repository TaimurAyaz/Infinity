//
//  PhotoViewController.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit

// photo cell identifier.
private let kPhotoCellId = "kPhotoCellId"

/// A class responsible for previewing the photos.
class PhotoViewController: UIViewController {

    // Weak reference to the parents manager.
    weak var parentManager: CollectionManager?
    
    // Weak reference to the parent's pagination manager delegate.
    weak var parentPaginationManagerDelegate: PaginationManagerDelegate?
    
    // Protocol for updating the parent based on this view controller.
    weak var parentUpdating: PhotoViewControllerParentUpdating?
    
    // The  collection view's pagination manager. This manager forwards its actions to the parent's pagination delegate.
    private var paginationManager: PaginationManager?
    
    // The currently displayed page. This is translated to an indexPath on the parent controller, since, we have a shared datasource.
    private var currentPage: Int = 0 {
        didSet {
            parentUpdating?.photoViewController(self, didScrollToItemAtIndex: currentPage)
        }
    }
    
    // The collection view.
    private var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pagingEnabled = true
        view.backgroundColor = UIColor.clearColor()
        view.registerClass(PhotoCell.self, forCellWithReuseIdentifier: kPhotoCellId)
        return view
    }()
    
    // The `X` button to dismiss previewing.
    private let dismissButton: UIButton = {
        let view = UIButton(type: .Custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = UIColor.whiteColor()
        view.imageView?.contentMode = .ScaleAspectFit
        view.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 12, 12)
        view.contentHorizontalAlignment = .Left
        view.setImage(UIImage(named: "close_button")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSizeZero
        view.layer.shadowRadius = 7
        view.layer.shadowOpacity = 0.8
        return view
    }()
    
    // The initial indexPath to preview. This is used to facilite showing the correct photo the user is trying to preview.
    private(set) var initialIndex: NSIndexPath?
    
    
    /// Custom initializer that asks for required properties. These properties can be set manually as well.
    ///
    /// - parameter parentManager:                   Reference to the parent's manager to use as a datasource.
    /// - parameter parentPaginationManagerDelegate: Reference to the parent's pagination delegate to forward our pagination delegate to.
    /// - parameter initialIndex:                    The initial index to display.
    ///
    /// - returns: A newly created `PhotoViewController`
    convenience init(parentManager: CollectionManager, parentPaginationManagerDelegate: PaginationManagerDelegate?, initialIndex: NSIndexPath) {
        self.init()
        self.parentManager = parentManager
        self.initialIndex = initialIndex
        self.parentPaginationManagerDelegate = parentPaginationManagerDelegate
    }
}


extension PhotoViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(dismissButton)
        
        paginationManager = PaginationManager(collectionView: collectionView, direction: .horizontal)
        paginationManager?.delegate = self
        
        
        let views = ["collectionView" : collectionView, "dismissButton" : dismissButton]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(5)-[dismissButton(==44)]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(5)-[dismissButton(==44)]", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    // Scroll to the initial index before the view appears.
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let initialIndex = initialIndex else { return }
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        collectionView.scrollToItemAtIndexPath(initialIndex, atScrollPosition: .None, animated: false)
    }
    
    // We make sure to scroll to the current page when orientation changes.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if collectionView.indexPathsForVisibleItems().contains(NSIndexPath(forItem: currentPage, inSection: 0)) == false {
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentPage, inSection: 0), atScrollPosition: .None, animated: false)
        }
    }
    
    // As the size changes, we need to recalculate the current page based on the new size.
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        let newOffset = size.width * collectionView.contentOffset.x / collectionView.bounds.size.width
        let targetPage = Int(floor(newOffset / size.width))
        currentPage = targetPage >= 0 ? targetPage : 0
        collectionView.reloadData()
    }
}


// Mark:- Dismiss
private extension PhotoViewController {
    
    // This method dismissed previewing and return to parent.
    @objc func dismissButtonTapped(button: UIButton) {
        parentUpdating?.photoViewController(self, willDismissFromItemAtIndex: currentPage)
        dismissViewControllerAnimated(true, completion: nil)
    }
}


extension PhotoViewController: PaginationManagerDelegate {
    
    // We simply defer to the parent for fetching new data and then reload our collection view with the new data.
    func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock) {
        parentPaginationManagerDelegate?.paginationManagerDidExceedThreshold(manager, threshold: threshold, reset: { [weak self] (shouldReset) in
            reset(shouldReset: shouldReset)
            if shouldReset {
                self?.collectionView.reloadData()
            }
        })
    }
}


extension PhotoViewController: UICollectionViewDelegate {
    
    // Calculate the current page as the user scrolls.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let targetPage = Int(floor(scrollView.contentOffset.x / scrollView.bounds.size.width))
        currentPage = targetPage >= 0 ? targetPage : 0
    }
}


extension PhotoViewController: UICollectionViewDataSource {
    
    // We only require one section
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Defer to the parent for the number of items.
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let parentManager = parentManager else { return 0 }
        return parentManager.items.count
    }
    
    // Create the photo cell and populate it with the given photo. Initially this photo will be the same resolution as the parent's grid.
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kPhotoCellId, forIndexPath: indexPath)
        
        configureCell(cell,
                      atIndexPath: indexPath,
                      forSizeId: correctedSizeIdForVariant(.normal),
                      shouldAnimateFromBlank: true)
        return cell
    }
    
    // We try to re-configure the cell with higher resolution photo as the cell is about to display. This way the user gets a near seamless experience.
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        configureCell(cell,
                      atIndexPath: indexPath,
                      forSizeId: PhotoSizeManager.shared.currentSize.sizeIdForVariant(.large),
                      shouldAnimateFromBlank: false)
    }
    
    // Convenience method to get the corrent size id for the photo. 
    // For the constraints of this assignment, we are asked to display an original aspect photo even for a square parent grid. 
    // For that reason, we need this method to pass back the large variant of the uncropped photo even at `cellForItemAtIndexPath:`
    private func correctedSizeIdForVariant(variant: PhotoSizeVariant) -> Int {
        var sizeId: Int = PhotoSizeManager.shared.currentSize.sizeIdForVariant(variant)
        if PhotoSizeManager.shared.currentSize == .cropped {
            sizeId = PhotoSizeManager.shared.currentSize.sizeIdForVariant(.large)
        }
        return sizeId
    }
    
    
    // Convenience method to configure the cell.
    private func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath, forSizeId sizeId:Int, shouldAnimateFromBlank fromBlank: Bool) {
        if let cell = cell as? PhotoCellConfigurating, parentManager = parentManager {
            cell.configure(withPhoto: parentManager.items[indexPath.row], sizeId: sizeId, fadeFromBlank: fromBlank)
        }
    }
}


// Layout for each photo cell.
extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}
