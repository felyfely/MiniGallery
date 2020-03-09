//
//  ViewController.swift
//  miniGallery
//
//  Created by 付 旦 on 3/8/20.
//  Copyright © 2020 付 旦. All rights reserved.
//

import UIKit
import MiniGalleryUI
import DataSynchronization
import os

extension DataRequestable {
    /// if host is common
    var host: String {
        return "https://private-04a55-videoplayer1.apiary-mock.com"
    }
}

struct GalleryItemsQueryRequest: DataRequestable {
    var path: String {
        return "pictures"
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func queryItems(_ sender: Any) {
        queryItems()
    }
    
    func queryItems() {
        statusLabel.text = "Loading..."
        GalleryItemsQueryRequest().request { [weak self] (result: Result<[GalleryItem], Error>) in
            switch result {
            case .success(let items):
                DispatchQueue.main.async {
                    self?.statusLabel.text = "Success !"
                    self?.showGalleryUI(with: items)
                }
            case .failure(let error):
                os_log(.error, "@", error.localizedDescription)
                DispatchQueue.main.async {
                    self?.statusLabel.text = error.localizedDescription
                }
            }
        }
    }
    
    func showGalleryUI(with items: [GalleryItem]) {
        let galleryUIViewController = MiniGalleryUIServiceProvider.getMiniGalleryUIViewController(items: items)
        navigationController?.pushViewController(galleryUIViewController, animated: true)
    }

}
