//
//  PhotoPresentedAnimationController.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

/// The presentation animator for presenting `PhotoViewController`
class PhotoPresentedAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else { transitionContext.completeTransition(false); return }
        let containerView = transitionContext.containerView()
        
        containerView.addSubview(toViewController.view)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {}, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
