//
//  PhoneVerifyViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/16/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class PhoneVerifyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
