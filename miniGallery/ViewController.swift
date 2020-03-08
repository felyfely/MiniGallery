//
//  ViewController.swift
//  miniGallery
//
//  Created by 付 旦 on 3/8/20.
//  Copyright © 2020 付 旦. All rights reserved.
//

import UIKit

struct GalleryItem: Codable, Hashable {
    let id: Int
    let imageUrl: URL
    let videoUrl: URL
    var typeId: String?
}

class VideoCell: UICollectionViewCell {
    static let reuseIdentifer = "VideoCell"
    
}

class CoverCell: UICollectionViewCell {
    static let reuseIdentifer = "CoverCell"
}

class ViewController: UIViewController, UICollectionViewDelegate {
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    let endPointUrl = URL(string: "https://private-04a55-videoplayer1.apiary-mock.com/pictures")!
    
    enum Section: String, CaseIterable {
        case video = "vid", cover = ""
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, GalleryItem>! = nil
    
    var items = [GalleryItem]()
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = generateLayout()
        configureDataSource()
        queryItems()
        // Do any additional setup after loading the view.
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <Section, GalleryItem>(collectionView: collectionView) {
                (collectionView: UICollectionView, indexPath: IndexPath, albumItem: GalleryItem) -> UICollectionViewCell? in
                
                let sectionType = Section.allCases[indexPath.section]
                switch sectionType {
                case .video:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: VideoCell.reuseIdentifer,
                        for: indexPath) as? VideoCell else { fatalError("Could not create new cell") }
                    // configure cell
                    return cell
                    
                case .cover:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CoverCell.reuseIdentifer,
                        for: indexPath) as? CoverCell else { fatalError("Could not create new cell") }
                    //TODO configure cell
                    return cell
                    
                }
        }
        reloadData()
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, GalleryItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, GalleryItem>()
        snapshot.appendSections([Section.video])
        let videoItems = items.compactMap { (item) -> GalleryItem? in
            var itemCopy = item
            itemCopy.typeId = Section.video.rawValue
            return itemCopy
        }
        snapshot.appendItems(videoItems, toSection: Section.video)
        let coverItems = items.compactMap { (item) -> GalleryItem? in
            var itemCopy = item
            itemCopy.typeId = Section.cover.rawValue
            return itemCopy
        }
        snapshot.appendSections([Section.cover])
        snapshot.appendItems(coverItems, toSection: Section.cover)
        
        return snapshot
    }
    
    func reloadData() {
        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func queryItems() {
        let request = URLRequest(url: endPointUrl)
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let data = data {
                do {
                    // Convert the data to JSON
                    let items = try JSONDecoder.init().decode([GalleryItem].self, from: data)
                    self.items = items
                    DispatchQueue.main.async {
                        self.reloadData()
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
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let sectionLayoutKind = Section.allCases[sectionIndex]
            switch (sectionLayoutKind) {
            case .video: return self.generateVideoLayout()
            case .cover: return self.generateCoverLayout()
            }
        }
        return layout
    }
    
    func generateVideoLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                              heightDimension: .fractionalHeight(0.9))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Show one item plus peek on narrow screens, two items plus peek on wider screens
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        //      section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    func generateCoverLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Show one item plus peek on narrow screens, two items plus peek on wider screens
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(128))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return section
    }
    
    
}

