//
//  MainBroadcaster.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/13/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation
import AVKit
import mobileffmpeg

func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

class MainBroadcaster {

    static var shared = MainBroadcaster()
    
    public var broadcastUrl: URL?
    public var rate = 44100
    public var acodec = "aac"
    public var outputFormat = "flv"
    
    var task: DispatchWorkItem?
    
    private init () {
    }
    
    func start(url: URL, padding: Int) {
        if task != nil {
            MobileFFmpeg.cancel()
        }
        
        task?.wait()
        
        task = DispatchWorkItem(qos: .background) {
            let (h, m, s) = secondsToHoursMinutesSeconds(seconds: padding)
            let ss = String(format: "%02d:%02d:%02d", h, m, s)
            if let brUrl = self.broadcastUrl {
                MobileFFmpeg.execute("-re -ss \(ss) -i \(url.absoluteString) -vn -c:a \(self.acodec) -ar \(self.rate) -ac 2 -f \(self.outputFormat) \(brUrl)")
            }
            self.task = nil
        }
        
        DispatchQueue.global(qos: .background)
            .async(execute: task!)
    }
    
    func stop() {
        if task != nil {
            MobileFFmpeg.cancel()
        }
        task?.wait()
        task = nil
    }

}
