//
//  MainNavigationController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/17/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit


class MainNavigationController: UINavigationController {
    
    var tokenAuthData: TokenAuthData!

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(tokenAuthData.token, forKey: "token")
    }

}
