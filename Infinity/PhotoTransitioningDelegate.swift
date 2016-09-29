//
//  PhotoTransitioningDelegate.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

/// The transitioning delegate for transitioning to/from a `PhotoViewController`
class PhotoTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    // Weak reference to the `PhotoPresenting` conforming object.
    weak var photoPresenting: PhotoPresenting?
    
    convenience init(photoPresenting: PhotoPresenting) {
        self.init()
        self.photoPresenting = photoPresenting
    }
    
    // The presentation controller for the transition.
    @objc func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController?, sourceViewController source: UIViewController) -> UIPresentationController? {
        return PhotoPresentationController(presentedViewController: presented, presentingViewController: presenting, photoPresenting: photoPresenting)
    }
    
    // The presentation animator.
    @objc func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoPresentedAnimationController()
    }
    
    // The dismissal animator.
    @objc func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoDismissedAnimationController()
    }
}
