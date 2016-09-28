//
//  CollectionManager.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import AlamofireImage

private let kCollectionManagerCellId = "kCollectionManagerCellId"

class CollectionManager: NSObject {
    
    var items: [Photo] = [] {
        didSet {
            reload()
        }
    }
    
    private weak var collectionView: UICollectionView?
    
    init(collectionView: UICollectionView, items: [Photo] = []) {
        self.collectionView = collectionView
        self.collectionView?.collectionViewLayout = GalleryLayout()
        self.items = items
        super.init()
        setup()
    }
    
    func reload(withSize: CGSize? = nil) {
        guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? GalleryLayout else { return }
        layout.prepareLayout(withItems: items, andTargetSize: withSize)
        collectionView.reloadData()
    }
}

private extension CollectionManager {
    
    func setup() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.registerClass(GalleryCell.self, forCellWithReuseIdentifier: kCollectionManagerCellId)
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }
}

extension CollectionManager: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let target = collectionView.targetForAction(#selector(PhotoCellSelecting.didSelectPhoto(atIndexPath:)), withSender: self) as? PhotoCellSelecting {
            target.didSelectPhoto(atIndexPath: indexPath)
        }
    }
}

extension CollectionManager: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionManagerCellId, forIndexPath: indexPath)
        if let cell = cell as? PhotoCellConfigurating {
            cell.configure(withPhoto: items[indexPath.row], sizeId: PhotoSizeManager.shared.currentSize.sizeIdForVariant(.normal), fadeFromBlank: true)
            
            // Preload large size photo for previewing
            if PhotoSizeManager.shared.currentSize == .cropped {
                let imageLink = items[indexPath.row].imageLinkFor(size: PhotoSizeManager.shared.currentSize.sizeIdForVariant(.large))
                if let url = NSURL(string: imageLink.url) {
                    ImageDownloader.defaultInstance.downloadImage(URLRequest: NSURLRequest(URL: url), completion: nil)
                }
            }
        }
        return cell
    }
}


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
