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

class MainPlayer : PlayerIOClientDeletate {
    
    static var shared = MainPlayer()
    
    private var player: AVPlayer!
    
    var source: Source? {
        
        didSet {
            if let url = source?.getUrl() {
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                if isBroadcasted {
                    SocketIOManager.shared.setSource(source: source)
                }
            }
        }
        
    }
    
    var isPlaying: Bool = false
    
    var isBroadcasted: Bool = false {
        
        didSet {
            if isBroadcasted {
                SocketIOManager.shared.broadcastOn()
            } else {
                SocketIOManager.shared.broadcastOff()
            }
        }
        
    }
    
    private init () {
        player = AVPlayer()
        SocketIOManager.shared.playerDelegate = self
    }
    
    func play() {
        isPlaying = true
        player.play()
//        if isBroadcasted, let url = source?.getUrl() {
//            MainBroadcaster.shared.stop()
//            MainBroadcaster.shared.start(url: url, padding: Int(player.currentTime().seconds))
//        }
        if isBroadcasted {
            SocketIOManager.shared.playSong()
        }
    }
    
    func pause() {
        isPlaying = false
        player.pause()
//        if isBroadcasted {
//            MainBroadcaster.shared.stop()
//        }
        if isBroadcasted {
            SocketIOManager.shared.pauseSong()
        }
    }
    
    func seek(padding: Double) {
        player.seek(to: CMTime(seconds: padding, preferredTimescale: 60000))
//        if isBroadcasted, let url = source?.getUrl() {
//            MainBroadcaster.shared.stop()
//            MainBroadcaster.shared.start(url: url, padding: Int(player.currentTime().seconds))
//        }
        if isBroadcasted {
            SocketIOManager.shared.seekSong(padding: padding)
        }
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
    
    func setSourceFromBroadcast(source: Source) {
        print("TEST", "Set Source")
    }
    
    func playFromBroadcast() {
        print("TEST", "Play Source")
    }
    
    func pauseFromBroadcast() {
        print("TEST", "Pause Source")
    }
    
    func seekFromBroadcast(padding: Double) {
        print("TEST", "Seek Source")
    }
    
}
