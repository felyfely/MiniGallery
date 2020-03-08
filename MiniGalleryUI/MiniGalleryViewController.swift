//
//  MiniGalleryViewController.swift
//  miniGallery
//
//  Created by 付 旦 on 3/8/20.
//  Copyright © 2020 付 旦. All rights reserved.
//

import UIKit
import AVKit
import os

class MiniGalleryCollectionViewCoverCell: UICollectionViewCell {
    
    static let reuseIdentifer = "MiniGalleryCollectionViewCoverCell"
    
    var currentModel: GalleryItem?
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    func bind(model: GalleryItem) {
        // test image cache
        currentModel = model
        loadImage(imageUrl: model.imageUrl) { [weak self] (url, image) in
            if self?.currentModel?.imageUrl == url {
                DispatchQueue.main.async {
                    self?.coverImageView.image = image
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

class MiniGalleryViewModel {
    var items = [GalleryItem]()
    func item(at index: Int) -> GalleryItem? {
        if index >= 0, index < items.count {
            return items[index]
        }
        return nil
    }
    
    func index(of item: GalleryItem) -> Int? {
        return items.firstIndex(of: item)
    }
}

class MiniGalleryViewController: UIViewController {
    
    weak var pageController: MiniGalleryVideoPageViewController?
    
    lazy var viewModel = MiniGalleryViewModel()
    
    var lastSelectedIndexPath: IndexPath?
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageController = segue.destination as? MiniGalleryVideoPageViewController {
            self.pageController = pageController
            pageController.selectionDelegate = self
            pageController.set(items: viewModel.items)
        }
    }
    
    func set(items: [GalleryItem]) {
        viewModel.items = items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        // Do any additional setup after loading the view.
    }
    
    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = .fast
        DispatchQueue.main.async {
            self.select(at: IndexPath.init(row: 0, section: 0), selectPage: false)
        }
    }
    
    func select(at indexPath: IndexPath, selectPage: Bool = true) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        guard indexPath != lastSelectedIndexPath else { return }
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
        
        if selectPage, let item = viewModel.item(at: indexPath.row) {
            pageController?.select(at: item, forward: indexPath.row > (lastSelectedIndexPath?.row ?? 0))
        }
        lastSelectedIndexPath = indexPath
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flowLayout?.invalidateLayout()
        collectionView.contentInset = .init(top: 0, left: collectionView.frame.width / 4, bottom: 0, right: collectionView.frame.width / 4)
    }
    
    static func loadFromStoryboard() -> Self {
        let storyboard = UIStoryboard.init(name: "MiniGalleryUI", bundle: currentBundle)
        return storyboard.instantiateViewController(withIdentifier: "MiniGalleryViewController") as! Self
    }
}

extension MiniGalleryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MiniGalleryCollectionViewCoverCell.reuseIdentifer, for: indexPath) as! MiniGalleryCollectionViewCoverCell
        viewModel.item(at: indexPath.row).flatMap { cell.bind(model: $0)}
        return cell
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
            select(at: IndexPath.init(row: offsetIndex, section: 0))
        }
    }
}

extension MiniGalleryViewController: GalleryPageSelectionDelegate {
    func didSelect(at item: GalleryItem) {
        if let index = viewModel.index(of: item) {
            select(at: IndexPath.init(row: index, section: 0), selectPage: false)
        }
    }
}
