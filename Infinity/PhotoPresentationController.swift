//
//  PhotoPresentationController.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoPresentationController: UIPresentationController {

    let dimmingView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.blackColor()
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .ScaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
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
        
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0.0
        containerView.insertSubview(dimmingView, atIndex: 0)
        
        photoPresenting.willPresentPhoto()
        let frame = photoPresenting.frameForPresentedItem
        imageView.frame = frame
        configureImageViewForCurrentSize()
        containerView.addSubview(imageView)
        
        presentedViewController.view.alpha = 0
        
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
        
        photoPresenting.willDismissPhoto()
        let frame = photoPresenting.frameForPresentedItem
        imageView.frame = finalImageViewFrameForPhoto(photoPresenting.photoForPresentedItem) ?? containerView.bounds
        configureImageViewForCurrentSize()
        containerView.addSubview(imageView)
        
        presentedViewController.view.alpha = 0
        
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ (coordinatorContext) -> Void in
            self.imageView.frame = frame
            self.dimmingView.alpha = 0.0
            }, completion: { _ in
                photoPresenting.didDismissPhoto()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView else { return }
        dimmingView.frame = containerView.bounds
        presentedView()?.frame = frameOfPresentedViewInContainerView()
    }
    
    private func configureImageViewForCurrentSize() {
        if let photo = photoPresenting?.photoForPresentedItem {
            var sizeId: Int = PhotoSizeManager.shared.currentSize.sizeIdForVariant(.normal)
            if PhotoSizeManager.shared.currentSize == .cropped {
                sizeId = PhotoSizeManager.shared.currentSize.sizeIdForVariant(.large)
            }
            if let url = NSURL(string: photo.imageLinkFor(size: sizeId).url) {
                imageView.af_setImageWithURL(url)
            }
        }
    }
    
    private func finalImageViewFrameForPhoto(photo: Photo?) -> CGRect? {
        if let photo = photo, containerView = containerView {
            let photoAspect = photo.size
            let returnSize = AVMakeRectWithAspectRatioInsideRect(photoAspect, containerView.bounds)
            return returnSize
        }
        return nil
    }
}
