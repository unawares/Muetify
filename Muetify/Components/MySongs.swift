//
//  MySongs.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/23/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


class MySongs {
    
    static var shared = MySongs()
    
    var songs = Set<Int>()
    
    func addSong(id: Int) {
        songs.insert(id)
    }
    
    func removeSong(id: Int) {
        songs.remove(id)
    }
    
    func hasSong(id: Int) -> Bool {
        return songs.contains(id)
    }
    
}
