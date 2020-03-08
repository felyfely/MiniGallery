//
//  MiniGalleryUIServiceProvider.swift
//  MiniGalleryUI
//
//  Created by 付 旦 on 3/8/20.
//  Copyright © 2020 付 旦. All rights reserved.
//

import Foundation
import UIKit

public struct GalleryItem: Codable, Hashable {
    public let id: Int
    public let imageUrl: URL
    public let videoUrl: URL
}

open class MiniGalleryUIServiceProvider {
    open class func getMiniGalleryUIViewController(items: [GalleryItem]) -> UIViewController {
        let miniGalleryUIViewController = MiniGalleryViewController.loadFromStoryboard()
        miniGalleryUIViewController.items = items
        return miniGalleryUIViewController
    }
}

let currentBundle = Bundle.init(for: MiniGalleryUIServiceProvider.self)
