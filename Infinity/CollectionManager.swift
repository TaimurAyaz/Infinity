//
//  CollectionManager.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import AlamofireImage

// Reuse identifier of the gallery cell.
private let kCollectionManagerCellId = "kCollectionManagerCellId"

/// The manager for the gallery collection view.
class CollectionManager: NSObject {
    
    // An array of `Photo` objects to display.
    var items: [Photo] = [] {
        didSet {
            reload()
        }
    }
    
    // Weak reference to the collectionView.
    private weak var collectionView: UICollectionView?
    
    
    /// Designated initializer for the manager.
    ///
    /// - parameter collectionView: The associated collection view.
    /// - parameter items:          `Optional:` An array of items to display.
    ///
    /// - returns: A newly created manager.
    init(collectionView: UICollectionView, items: [Photo] = []) {
        self.collectionView = collectionView
        self.collectionView?.collectionViewLayout = GalleryLayout()
        self.items = items
        super.init()
        setup()
    }
    
    
    /// Reloads the collection view.
    ///
    /// - parameter withSize: `Optional:` The target size of the collection view. Useful for layout changes during orientation change.
    func reload(withSize: CGSize? = nil) {
        guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? GalleryLayout else { return }
        layout.prepareLayout(withItems: items, andContainerSize: withSize)
        collectionView.reloadData()
    }
}

private extension CollectionManager {
    
    // Setup the collection view.
    func setup() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.registerClass(GalleryCell.self, forCellWithReuseIdentifier: kCollectionManagerCellId)
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }
}

extension CollectionManager: UICollectionViewDelegate {
    
    // Pass the `PhotoCellSelecting` method.
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let target = collectionView.targetForAction(#selector(PhotoCellSelecting.didSelectPhoto(atIndexPath:)), withSender: self) as? PhotoCellSelecting {
            target.didSelectPhoto(atIndexPath: indexPath)
        }
    }
}

extension CollectionManager: UICollectionViewDataSource {
    
    // We only require one section.
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The number items based on the given `Photo` objects array.
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    // Configure the cell.
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionManagerCellId, forIndexPath: indexPath)
        if let cell = cell as? PhotoCellConfigurating {
            cell.configure(withPhoto: items[indexPath.row], sizeId: PhotoSizeManager.shared.currentSize.sizeIdForVariant(.normal), fadeFromBlank: true)
            
            // Preload large size photo for previewing, if the current size is cropped.
            if PhotoSizeManager.shared.currentSize == .cropped {
                let url = items[indexPath.row].imageURLFor(sizeId: PhotoSizeManager.shared.currentSize.sizeIdForVariant(.large))
                ImageDownloader.defaultInstance.downloadImage(URLRequest: NSURLRequest(URL: url), completion: nil)
            }
        }
        return cell
    }
}


// Required layout delegate methods.
extension CollectionManager: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        guard let layout = collectionViewLayout as? GalleryLayout else { return 0 }
        return layout.interItemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        guard let layout = collectionViewLayout as? GalleryLayout else { return 0 }
        return layout.interItemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? GalleryLayout else { return CGSizeZero }
        return layout.size(forItemAtIndexPath: indexPath)
    }
}
