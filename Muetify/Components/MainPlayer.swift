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
    private var timer: Timer!
    private var lastTime: Double = 0
    
    var source: Source? {
        
        didSet {
            reload()
        }
        
    }
    
    var isPlaying: Bool = false
    var isBroadcasted: Bool = false
    
    private init () {
        player = AVPlayer()
        timer = Timer(timeInterval: 1.0,
                            target: self,
                            selector: #selector(check),
                            userInfo: nil,
                            repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        timer.tolerance = 0.1
    }
    
    @objc func check() {
        if isPlaying, let currentTime = getCurrentTime() {
            if currentTime.seconds == lastTime {
                reload()
                player.play()
                print("Play")
            }
            lastTime = currentTime.seconds
        }
        
    }
    
    func reload() {
        if let url = source?.getUrl() {
            player.replaceCurrentItem(with: AVPlayerItem.init(url: url))
        }
    }
    
    func play() {
        isPlaying = true
        player.play()
        if isBroadcasted, let url = source?.getUrl() {
            MainBroadcaster.shared.start(url: url, padding: Int(player.currentTime().seconds))
        }
    }
    
    func start(padding: Double) {
        player.seek(to: CMTime(seconds: padding, preferredTimescale: 60000))
        isPlaying = true
        player.play()
        if isBroadcasted, let url = source?.getUrl() {
            MainBroadcaster.shared.start(url: url, padding: Int(padding))
        }
    }
    
    func pause() {
        isPlaying = false
        player.pause()
        MainBroadcaster.shared.stop()
    }
    
    func getDuration() -> CMTime? {
        return self.player.currentItem?.asset.duration
    }
    
    func getCurrentTime() -> CMTime? {
        return self.player.currentTime()
    }
    
}
