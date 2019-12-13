//
//  Contact.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/13/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


class Contact : Item {
    
    var fullName: String
    var statusInfo: String
    
    init(fullName: String, statusInfo: String) {
        self.fullName = fullName
        self.statusInfo = statusInfo
    }
    
}
