//
//  Song.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/13/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


class Song : Item, Source {
    
    var url: URL
    var title: String
    var singer: String
    var duration: TimeInterval
    
    init(url: URL, title: String, singer: String, duration: TimeInterval) {
        self.url = url
        self.title = title
        self.singer = singer
        self.duration = duration
    }
    
    func getUrl() -> URL {
        return url
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getSinger() -> String {
        return singer
    }
    
}
