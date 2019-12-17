//
//  Authentication.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/17/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation



struct PhoneNumberModel: Decodable {
    
    var phoneNumber: String
    
}

extension PhoneNumberModel {
    
    init?(json: JSON?) {
        if let json = json {
            self.phoneNumber = json["phone_number"] as! String
        } else {
            return nil
        }
    }
    
}


struct SignInData: Decodable {
    
    var uuid: String
    var data: String
    
}


struct UserData: Decodable {
    
    var id: Int
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var avatar: String?
    
}


extension UserData {
    
    init?(json: JSON?) {
        if let json = json {
            self.id = json["id"] as! Int
            self.firstName = json["first_name"] as! String
            self.lastName = json["last_name"] as! String
            self.phoneNumber = json["phone_number"] as! String
            self.avatar = json["avatar"] as? String
        } else {
            return nil
        }
    }
    
}


struct SignUpData: Decodable {
    
    var uuid: String
    var data: String
    var userData: UserData
    
}


struct TokenAuthData: Decodable {
    
    var token: String
    var userData: UserData?
    
}


extension TokenAuthData {
    
    init?(json: JSON?) {
        if let json = json {
            self.token = json["token"] as! String
            self.userData = UserData(json: json["user"] as? JSON)
        } else {
            return nil
        }
    }
    
}
