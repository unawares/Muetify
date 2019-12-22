//
//  BroadcastUrl.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/22/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


class Broadcast {
    
    var id: Int
    var user: Contact
    var data: JSON?
    
    init(id: Int, user: Contact, data: JSON?) {
        self.id = id
        self.user = user
        self.data = data
    }
    
}
