//
//  ViewController.swift
//  miniGallery
//
//  Created by 付 旦 on 3/8/20.
//  Copyright © 2020 付 旦. All rights reserved.
//

import UIKit
import MiniGalleryUI

let endPointUrl = URL(string: "https://private-04a55-videoplayer1.apiary-mock.com/pictures")!
let urlQueryCacheKey = "urlQueryCacheKey"

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func queryItems(_ sender: Any) {
        queryItems()
    }
    
    func queryItems() {
        if let data = UserDefaults.standard.data(forKey: urlQueryCacheKey), let items = try? JSONDecoder.init().decode([GalleryItem].self, from: data) {
            showGalleryUI(with: items)
            return
        }
        
        let request = URLRequest(url: endPointUrl)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let `self` = self else { return }
            if let data = data {
                do {
                    // Convert the data to JSON
                    let items = try JSONDecoder.init().decode([GalleryItem].self, from: data)
                    UserDefaults.standard.set(data, forKey: urlQueryCacheKey)
                    DispatchQueue.main.async {
                        self.showGalleryUI(with: items)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func showGalleryUI(with items: [GalleryItem]) {
        let galleryUIViewController = MiniGalleryUIServiceProvider.getMiniGalleryUIViewController(items: items)
        navigationController?.pushViewController(galleryUIViewController, animated: true)
    }

    
}

