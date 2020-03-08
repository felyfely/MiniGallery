//
//  MiniGalleryUIServiceProvider.swift
//  MiniGalleryUI
//
//  Created by 付 旦 on 3/8/20.
//  Copyright © 2020 付 旦. All rights reserved.
//

import Foundation
import UIKit

open class MiniGalleryUIServiceProvider {
    open class func getMiniGalleryUIViewController(items: [GalleryItem]) -> UIViewController {
        let miniGalleryUIViewController = MiniGalleryViewController.loadFromStoryboard()
        miniGalleryUIViewController.set(items: items)
        return miniGalleryUIViewController
    }
}
