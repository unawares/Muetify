//
//  ProfileViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/16/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
