//
//  Album.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/23/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation

class Album : Item {
    
    var albumBase: AlbumBase
    
    init(albumBase: AlbumBase) {
        self.albumBase = albumBase
    }
    
}
