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


protocol BroadcastPlayerDelegate {
    
    func changedSource()
    
}

class MainPlayer : PlayerIOClientDeletate {
    
    static var shared = MainPlayer()
    
    var delegate: BroadcastPlayerDelegate?
    
    private var player: AVPlayer!
    
    var source: Source? {
        
        didSet {
            if let url = source?.getUrl() {
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                if isBroadcasted {
                    SocketIOManager.shared.setSource(source: source)
                }
            }
            if broadcast != nil {
                delegate?.changedSource()
            }
        }
        
    }
    
    var broadcast: Broadcast?
    
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
    }
    
    func play() {
        isPlaying = true
        player.play()
        if isBroadcasted {
            SocketIOManager.shared.playSong()
        }
        leave()
    }
    
    func pause() {
        isPlaying = false
        player.pause()
        if isBroadcasted {
            SocketIOManager.shared.pauseSong()
        }
        leave()
    }
    
    func seek(padding: Double) {
        player.seek(to: CMTime(seconds: padding, preferredTimescale: 60000))
        if isBroadcasted {
            SocketIOManager.shared.seekSong(padding: padding)
        }
        leave()
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
        if broadcast != nil {
            self.source = source
        }
    }
    
    func playFromBroadcast() {
        if broadcast != nil {
            isPlaying = true
            player.play()
            if isBroadcasted {
                SocketIOManager.shared.playSong()
            }
        }
    }
    
    func pauseFromBroadcast() {
        if broadcast != nil {
            isPlaying = false
            player.pause()
            if isBroadcasted {
                SocketIOManager.shared.pauseSong()
            }
        }
    }
    
    func seekFromBroadcast(padding: Double) {
        if broadcast != nil {
            player.seek(to: CMTime(seconds: padding, preferredTimescale: 60000))
            if isBroadcasted {
                SocketIOManager.shared.seekSong(padding: padding)
            }
        }
    }
    
    func join(broadcast: Broadcast) {
        self.broadcast = broadcast
        SocketIOManager.shared.playerDelegate = self
    }
    
    func leave() {
        SocketIOManager.shared.playerDelegate = nil
        if let broadcast = broadcast {
            SocketIOManager.shared.leave(broadcastId: broadcast.id)
        }
        broadcast = nil
    }
    
}
