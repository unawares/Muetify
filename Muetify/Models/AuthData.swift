//
//  AuthData.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/17/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct AuthData {
    
    var uuid: String?
    var data: String?
    var isRegistered: Bool?
    
    init(snapshot: DocumentSnapshot) {
        if let document = snapshot.data() {
            uuid = document["uuid"] as? String
            data = document["data"] as? String
            isRegistered = document["is_registered"] as? Bool
        }
    }
    
}
