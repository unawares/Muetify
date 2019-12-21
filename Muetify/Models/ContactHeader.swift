//
//  ContactHeader.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/21/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


class ContactHeader : Item {
    
    var fullName: String
    var phoneNumber: String
    var avatar: String?
    
    init(fullName: String, phoneNumber: String, avatar: String?) {
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.avatar = avatar
    }
    
}
