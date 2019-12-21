//
//  Contact.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/13/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


class Contact : Item {
    
    var id: Int
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var avatar: String?
    
    init(id: Int, firstName: String, lastName: String, phoneNumber: String, avatar: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.avatar = avatar
    }
    
}
