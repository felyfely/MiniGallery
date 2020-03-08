//
//  MiniGalleryVideoPageViewController.swift
//  MiniGalleryUI
//
//  Created by 付 旦 on 3/8/20.
//  Copyright © 2020 付 旦. All rights reserved.
//

import UIKit

protocol GalleryPageSelectionDelegate: class {
    func didSelect(at item: GalleryItem)
}

class MiniGalleryVideoPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var selectionDelegate: GalleryPageSelectionDelegate?
    
    private var items = [GalleryItem]()
        
    func select(at item: GalleryItem, forward: Bool) {
        let videoPlayerController = MiniGalleryVideoPlayerController.init(item: item)
        setViewControllers([videoPlayerController], direction: forward ? .forward : .reverse, animated: true, completion: nil)
    }
    
    func next(of item: GalleryItem) -> GalleryItem? {
        if let index = items.firstIndex(of: item), (index + 1) < items.count {
            return items[index + 1]
        }
        return nil
    }
    
    func previous(of item: GalleryItem) -> GalleryItem? {
        if let index = items.firstIndex(of: item), (index - 1) >= 0 {
            return items[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let controller = viewController as? MiniGalleryVideoPlayerController, let previousItem = previous(of: controller.item) {
            return MiniGalleryVideoPlayerController.init(item: previousItem)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let controller = viewController as? MiniGalleryVideoPlayerController, let nextItem = next(of: controller.item) {
            return MiniGalleryVideoPlayerController.init(item: nextItem)
        }
        return nil
    }
        
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let viewController = viewControllers?.first as? MiniGalleryVideoPlayerController {
            selectionDelegate?.didSelect(at: viewController.item)
        }
        
    }
    
    func set(items: [GalleryItem]) {
        self.items = items
        if let firstItem = items.first {
            let playerVc = MiniGalleryVideoPlayerController.init(item: firstItem)
            setViewControllers([playerVc], direction: .forward, animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
       
        
    }
    
}
