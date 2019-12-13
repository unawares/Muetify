//
//  ItemsAlbumCollectionReusableView.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/9/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class ItemsHeaderCollectionReusableView: UICollectionReusableView {
    
    var filters: [String] = [
        "По жанрам",
        "По исполнителям",
        "По дате загрузки",
        "Сделать свое",
    ]
    
    
    override func awakeFromNib() {
    }
    
}
