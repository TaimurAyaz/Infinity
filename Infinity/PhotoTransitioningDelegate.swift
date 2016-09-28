//
//  PhotoTransitioningDelegate.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

class PhotoTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    weak var photoPresenting: PhotoPresenting?
    
    convenience init(photoPresenting: PhotoPresenting) {
        self.init()
        self.photoPresenting = photoPresenting
    }
    
    @objc func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController?, sourceViewController source: UIViewController) -> UIPresentationController? {
        return PhotoPresentationController(presentedViewController: presented, presentingViewController: presenting, photoPresenting: photoPresenting)
    }
    
    @objc func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoPresentedAnimationController()
    }
    
    @objc func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoDismissedAnimationController()
    }
}
