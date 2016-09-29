//
//  ToDictionarySpec.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-29.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import Quick
import Nimble
@testable import Infinity

class GalleryLayoutSpec: QuickSpec {
    
    override func spec() {
        
        let layout: GalleryLayout = GalleryLayout(maximumRowHeight: 200, interItemSpacing: 2)
        let _ = UICollectionView(frame: CGRectMake(0, 0, 1920, 1080), collectionViewLayout: layout)
        
        var sizes: [CGSize] = []
        
        for _ in 0..<100 {
            let randomWidth = CGFloat(500 + arc4random_uniform(1500))
            let randomHeight = CGFloat(500 + arc4random_uniform(1500))
            sizes.append(CGSizeMake(randomWidth, randomHeight))
        }
        
        layout.prepareLayout(sizes, andContainerSize: CGSizeMake(1920, 1080))
        
        describe("Gallery Layout") {
            
            it("should parse sizes less than or equal to the max height") {
                layout.itemSizes.forEach({
                    expect($0.height).to(beLessThanOrEqualTo(layout.maximumRowHeight))
                })
            }
            
            it("should parse sizes according to the aspect ratios") {
                layout.itemSizes.forEach({
                    let index = layout.itemSizes.indexOf($0)
                    let originalSize = sizes[index ?? 0]
                    expect($0.width / $0.height).to(beLessThanOrEqualTo( originalSize.width / originalSize.height ))
                })
            }
        }
    }
}
