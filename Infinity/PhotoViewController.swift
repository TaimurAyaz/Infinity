//
//  PhotoViewController.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit

private let kPhotoCellId = "kPhotoCellId"

class PhotoViewController: UIViewController {

    weak var parentManager: CollectionManager?
    weak var parentPaginationManagerDelegate: PaginationManagerDelegate?
    weak var parentUpdating: PhotoViewControllerParentUpdating?
    
    private var paginationManager: PaginationManager?
    
    private var currentPage: Int = 0 {
        didSet {
            parentUpdating?.photoViewController(self, didScrollToItemAtIndex: currentPage)
        }
    }
    
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
    
    private(set) var initialIndex: NSIndexPath?
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let initialIndex = initialIndex else { return }
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        collectionView.scrollToItemAtIndexPath(initialIndex, atScrollPosition: .None, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if collectionView.indexPathsForVisibleItems().contains(NSIndexPath(forItem: currentPage, inSection: 0)) == false {
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentPage, inSection: 0), atScrollPosition: .None, animated: false)
        }
    }
    
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
    @objc func dismissButtonTapped(button: UIButton) {
        parentUpdating?.photoViewController(self, willDismissFromItemAtIndex: currentPage)
        dismissViewControllerAnimated(true, completion: nil)
    }
}


extension PhotoViewController: PaginationManagerDelegate {
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
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let targetPage = Int(floor(scrollView.contentOffset.x / scrollView.bounds.size.width))
        currentPage = targetPage >= 0 ? targetPage : 0
    }
}


extension PhotoViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let parentManager = parentManager else { return 0 }
        return parentManager.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kPhotoCellId, forIndexPath: indexPath)
        
        configureCell(cell,
                      atIndexPath: indexPath,
                      forSizeId: correctedSizeIdForVariant(.normal),
                      shouldAnimateFromBlank: true)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        configureCell(cell,
                      atIndexPath: indexPath,
                      forSizeId: PhotoSizeManager.shared.currentSize.sizeIdForVariant(.large),
                      shouldAnimateFromBlank: false)
    }
    
    private func correctedSizeIdForVariant(variant: PhotoSizeVariant) -> Int {
        var sizeId: Int = PhotoSizeManager.shared.currentSize.sizeIdForVariant(variant)
        if PhotoSizeManager.shared.currentSize == .cropped {
            sizeId = PhotoSizeManager.shared.currentSize.sizeIdForVariant(.large)
        }
        return sizeId
    }
    
    private func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath, forSizeId sizeId:Int, shouldAnimateFromBlank fromBlank: Bool) {
        if let cell = cell as? PhotoCellConfigurating, parentManager = parentManager {
            cell.configure(withPhoto: parentManager.items[indexPath.row], sizeId: sizeId, fadeFromBlank: fromBlank)
        }
    }
}


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
