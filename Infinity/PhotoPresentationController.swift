//
//  PhotoPresentationController.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import AVFoundation

/// The presentation controller for the presenting `PhotoViewController`.
class PhotoPresentationController: UIPresentationController {

    // The background dimming view.
    let dimmingView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.blackColor()
        return view
    }()
    
    // The imageview for the image transition.
    let imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .ScaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    // Weak reference to the photo presenting options.
    weak var photoPresenting: PhotoPresenting?
    
    convenience init(presentedViewController: UIViewController, presentingViewController: UIViewController?, photoPresenting: PhotoPresenting?) {
        self.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        self.photoPresenting = photoPresenting
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let
            containerView = containerView,
            photoPresenting = photoPresenting else { return }
        
        // Add the dimming view.
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0.0
        containerView.insertSubview(dimmingView, atIndex: 0)
        
        // Pass the `PhotoPresenting` state methods.
        photoPresenting.willPresentPhoto()
        
        // Add the transition imageview.
        let frame = photoPresenting.frameForPresentedItem
        imageView.frame = frame
        configureImageViewForCurrentSize()
        containerView.addSubview(imageView)
        
        // Set the aplha of the `PhotoViewController` to zero and reset it once we complete the transition.
        presentedViewController.view.alpha = 0
        
        // Animate the imageview's frame with the transition and remove the imageview once the transition completes.
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ _ in
            self.dimmingView.alpha = 1.0
            self.imageView.frame = self.finalImageViewFrameForPhoto(photoPresenting.photoForPresentedItem) ?? containerView.bounds
            }, completion: { _ in
                self.presentedViewController.view.alpha = 1.0
                self.imageView.removeFromSuperview()
                photoPresenting.didPresentPhoto()
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let
            containerView = containerView,
            photoPresenting = photoPresenting else { return }
        
        // Pass the `PhotoPresenting` state methods.
        photoPresenting.willDismissPhoto()
        
        // Re-add the imageview with the current `PhotoViewController's` photo aspect.
        let frame = photoPresenting.frameForPresentedItem
        imageView.frame = finalImageViewFrameForPhoto(photoPresenting.photoForPresentedItem) ?? containerView.bounds
        configureImageViewForCurrentSize()
        containerView.addSubview(imageView)
        
        // Set the `PhotoViewController's` alpha to zero and let the presentation controller handle the dismissal transition.
        presentedViewController.view.alpha = 0
        
        // Animate the imageview's frame to the original cell in the `GalleryViewController`
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ (coordinatorContext) -> Void in
            self.imageView.frame = frame
            self.dimmingView.alpha = 0.0
            }, completion: { _ in
                photoPresenting.didDismissPhoto()
        })
    }
    
    
    // handle containerView frame changes.
    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView else { return }
        dimmingView.frame = containerView.bounds
        presentedView()?.frame = frameOfPresentedViewInContainerView()
    }
    
    
    // Convenience method to configure the imageView. We always set the `large` variant for cropped sizes.
    // This is done to facilitate the transition between cropped to full aspect for the given image.
    private func configureImageViewForCurrentSize() {
        if let photo = photoPresenting?.photoForPresentedItem {
           
            var sizeId: Int = PhotoSizeManager.shared.currentSize.sizeIdForVariant(.normal)
            if PhotoSizeManager.shared.currentSize == .cropped {
                sizeId = PhotoSizeManager.shared.currentSize.sizeIdForVariant(.large)
            }
            
            let url = photo.imageURLFor(sizeId: sizeId)
            imageView.af_setImageWithURL(url)
        }
    }
    
    // Convenience method to get the imageview's frame constraint to the image's aspect inside the containerview.
    private func finalImageViewFrameForPhoto(photo: Photo?) -> CGRect? {
        if let photo = photo, containerView = containerView {
            let photoAspect = photo.size
            let returnSize = AVMakeRectWithAspectRatioInsideRect(photoAspect, containerView.bounds)
            return returnSize
        }
        return nil
    }
}
