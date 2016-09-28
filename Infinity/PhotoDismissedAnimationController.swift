//
//  PhotoDismissedAnimationController.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import UIKit

class PhotoDismissedAnimationController: PhotoPresentedAnimationController {
    
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {}, completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}
