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
    
    static let reuseIdentifer = "MiniGalleryCollectionViewCoverCell"
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    func bind(model: GalleryItem) {
        // test image cache
        if let data = UserDefaults.standard.data(forKey: model.imageUrl.absoluteString) {
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.coverImageView.image = image
            }
        } else {
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: model.imageUrl)
                    UserDefaults.standard.set(data, forKey: model.imageUrl.absoluteString)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        transform = .identity
        coverImageView.image = nil
    }
}

class MiniGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var lastSelectedIndexPath: IndexPath?
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var pageController: MiniGalleryVideoPageViewController?
    
    var items = [GalleryItem]()
    
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageController = segue.destination as? MiniGalleryVideoPageViewController {
            self.pageController = pageController
            pageController.selectionDelegate = self
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
        collectionView.decelerationRate = .fast
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if let indexPath = collectionView.indexPathForItem(at: proposedContentOffset) {
            let width = collectionView.layoutMarginsGuide.layoutFrame.width / 2
            return CGPoint.init(x: width * CGFloat(indexPath.row) - collectionView.frame.width / 4, y: proposedContentOffset.y)
        }
        return proposedContentOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        let proposedContentOffset = targetContentOffset.pointee
        let offsetIndex = Int(round(proposedContentOffset.x / (collectionView.frame.width / 2) + 0.5))
        if offsetIndex >= 0 {
            let width = collectionView.layoutMarginsGuide.layoutFrame.width / 2
            let point = CGPoint.init(x: width * CGFloat(offsetIndex) - collectionView.frame.width / 4, y: proposedContentOffset.y)
            targetContentOffset.pointee = point
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        let offsetIndex = Int(round(collectionView.contentOffset.x / (collectionView.frame.width / 2) + 0.5))
        debugPrint(offsetIndex)
        select(at: IndexPath.init(row: offsetIndex, section: 0))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            guard let collectionView = scrollView as? UICollectionView else { return }
            let offsetIndex = Int(round(collectionView.contentOffset.x / (collectionView.frame.width / 2) + 0.5))
            debugPrint(offsetIndex)
            select(at: IndexPath.init(row: offsetIndex, section: 0))
        }
    }
    
    func select(at indexPath: IndexPath, selectPage: Bool = true) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        if indexPath != lastSelectedIndexPath {
            if let cell = collectionView.cellForItem(at: indexPath) {
                UIView.animate(withDuration: 0.25) {
                    cell.transform = .init(scaleX: 1.2, y: 1.2)
                }
            }
            if let lastIndexPath = lastSelectedIndexPath, let lastCell = collectionView.cellForItem(at: lastIndexPath) {
                UIView.animate(withDuration: 0.25) {
                    lastCell.transform = .identity
                }
            }
            
            if selectPage {
                let item = items[indexPath.row]
                pageController?.select(at: item, forward: indexPath.row > (lastSelectedIndexPath?.row ?? 0))
            }
            lastSelectedIndexPath = indexPath
            
        }
        
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
    
    static func loadFromStoryboard() -> Self {
        let storyboard = UIStoryboard.init(name: "MiniGalleryUI", bundle: currentBundle)
        return storyboard.instantiateViewController(withIdentifier: "MiniGalleryViewController") as! Self
    }
}

extension MiniGalleryViewController: GalleryPageSelectionDelegate {
    func didSelect(at item: GalleryItem) {
        if let index = items.firstIndex(of: item) {
            select(at: IndexPath.init(row: index, section: 0), selectPage: false)
        }
    }
}

protocol GalleryPageSelectionDelegate: class {
    func didSelect(at item: GalleryItem)
}

class MiniGalleryVideoPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var selectionDelegate: GalleryPageSelectionDelegate?
    
    var items = [GalleryItem]() {
        didSet {
            if let firstItem = items.first {
                let playerVc = MiniGalleryVideoPlayerController.init(item: firstItem)
                setViewControllers([playerVc], direction: .forward, animated: false, completion: nil)
            }
        }
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
}

class MiniGalleryVideoPlayerController: AVPlayerViewController {
    let item: GalleryItem
    private var playerLooper: AVPlayerLooper?
    
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
