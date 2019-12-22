//
//  Song.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/13/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


class Song : Item, Source {
    
    var id: Int
    var url: URL
    var title: String
    var singers: String
    var duration: TimeInterval
    
    init(id: Int, url: URL, title: String, singers: String, duration: TimeInterval) {
        self.id = id
        self.url = url
        self.title = title
        self.singers = singers
        self.duration = duration
    }
    
    func getId() -> Int {
        return id
    }
    
    func getUrl() -> URL {
        return url
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getSingers() -> String {
        return singers
    }
    
    func getDuration() -> TimeInterval {
        return duration
    }
    
}
