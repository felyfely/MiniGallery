//
//  MiniGalleryViewController.swift
//  miniGallery
//
//  Created by 付 旦 on 3/8/20.
//  Copyright © 2020 付 旦. All rights reserved.
//

import UIKit
import AVKit

class MiniGalleryCollectionViewCoverCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    static let reuseIdentifer = "MiniGalleryCollectionViewCoverCell"
    func bind(model: GalleryItem) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: model.imageUrl)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.coverImageView.image = image
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

class MiniGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let urlQueryCacheKey = "urlQueryKey"
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var pageController: MiniGalleryVideoPageViewController?
    
    var items = [GalleryItem]()
    
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    let endPointUrl = URL(string: "https://private-04a55-videoplayer1.apiary-mock.com/pictures")!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageController = segue.destination as? MiniGalleryVideoPageViewController {
            self.pageController = pageController
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MiniGalleryCollectionViewCoverCell.reuseIdentifer, for: indexPath) as! MiniGalleryCollectionViewCoverCell
        cell.bind(model: items[indexPath.row])
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        // Do any additional setup after loading the view.
        queryItems()
    }
    
    func queryItems() {
        if let data = UserDefaults.standard.data(forKey: urlQueryCacheKey), let items = try? JSONDecoder.init().decode([GalleryItem].self, from: data) {
            self.items = items
            collectionView.reloadData()
        }
        
        let request = URLRequest(url: endPointUrl)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let `self` = self else { return }
            if let data = data {
                do {
                    // Convert the data to JSON
                    let items = try JSONDecoder.init().decode([GalleryItem].self, from: data)
                    UserDefaults.standard.set(data, forKey: self.urlQueryCacheKey)
                    self.items = items
                    DispatchQueue.main.async {
                        self.updateUI()
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
    
    func updateUI() {
        collectionView.reloadData()
        pageController?.items = items
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flowLayout?.invalidateLayout()
        collectionView.contentInset = .init(top: 0, left: collectionView.frame.width / 4, bottom: 0, right: collectionView.frame.width / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginWidth = collectionView.layoutMarginsGuide.layoutFrame.width
        let height = collectionView.layoutMarginsGuide.layoutFrame.height
        let width = marginWidth / 2
        return CGSize.init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

class MiniGalleryVideoPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var items = [GalleryItem]() {
        didSet {
            if let firstItem = items.first {
                let playerVc = MiniGalleryVideoPlayerController.init(item: firstItem)
                setViewControllers([playerVc], direction: .forward, animated: false, completion: nil)
            }
        }
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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
}

class MiniGalleryVideoPlayerController: AVPlayerViewController {
    let item: GalleryItem
    var playerLooper: AVPlayerLooper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoGravity = .resizeAspectFill
        showsPlaybackControls = false
        let queuePlayer = AVQueuePlayer()
        let playerItem = AVPlayerItem(url: item.videoUrl)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        player = queuePlayer
        player?.play()
    }
    
    init(item: GalleryItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
