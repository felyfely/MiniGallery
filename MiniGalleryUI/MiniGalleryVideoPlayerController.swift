//
//  MiniGalleryVideoPlayerController.swift
//  MiniGalleryUI
//
//  Created by 付 旦 on 3/8/20.
//  Copyright © 2020 付 旦. All rights reserved.
//

import Foundation
import AVKit

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
