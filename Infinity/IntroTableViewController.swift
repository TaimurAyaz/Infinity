//
//  IntroTableViewController.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit

class IntroTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        let imageView = UIImageView(image: UIImage(named: "infinity_transparent"))
        imageView.contentMode = .ScaleAspectFit
        imageView.frame = CGRectMake(0, 0, 44, 44)
        navigationItem.titleView = imageView
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BaseCellId", forIndexPath: indexPath)
        cell.accessoryType = .DisclosureIndicator
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Modal - Cropped (440)"
            break
        case 1:
            cell.textLabel?.text = "Modal - Uncropped"
            break
        case 2:
            cell.textLabel?.text = "Navigation - Cropped (440)"
            break
        case 3:
            cell.textLabel?.text = "Navigation - Uncropped"
            break
        default:
            break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let galleryViewController = GalleryViewController()
        switch indexPath.row {
        case 0:
            PhotoSizeManager.shared.currentSize = .cropped
            let modalNavigationController = UINavigationController(rootViewController: galleryViewController)
            galleryViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismissModalNavigationController))
            galleryViewController.title = "Cropped (440)"
            presentViewController(modalNavigationController, animated: true, completion: nil)
            break
        case 1:
            PhotoSizeManager.shared.currentSize = .uncropped
            let modalNavigationController = UINavigationController(rootViewController: galleryViewController)
            galleryViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismissModalNavigationController))
            galleryViewController.title = "Uncropped"
            presentViewController(modalNavigationController, animated: true, completion: nil)
            break
        case 2:
            PhotoSizeManager.shared.currentSize = .cropped
            galleryViewController.title = "Cropped (440)"
            navigationController?.pushViewController(galleryViewController, animated: true)
            break
        case 3:
            PhotoSizeManager.shared.currentSize = .uncropped
            galleryViewController.title = "Uncropped"
            navigationController?.pushViewController(galleryViewController, animated: true)
            break
        default:
            break
        }
    }
    
    @objc private func dismissModalNavigationController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
