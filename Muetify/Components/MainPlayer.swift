//
//  Source.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/13/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class MainPlayer {
    
    static var shared = MainPlayer()
    
    private var player: AVPlayer!
    
    var source: Source? {
        
        didSet {
            if let url = source?.getUrl() {
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
            }
        }
        
    }
    
    var isPlaying: Bool = false
    
    private init () {
        player = AVPlayer()
    }
    
    func play() {
        isPlaying = true
        player.play()
    }
    
    func pause() {
        isPlaying = false
        player.pause()
    }
    
    func seek(padding: Double) {
        player.seek(to: CMTime(seconds: padding, preferredTimescale: 60000))
    }
    
    func getDuration() -> CMTime? {
        if let source = source {
            return CMTime(seconds: source.getDuration(), preferredTimescale: 1000000)
        }
        return nil
    }
    
    func getCurrentTime() -> CMTime? {
        let time = self.player.currentTime()
        return time.isValid ? time : nil
    }
    
}
