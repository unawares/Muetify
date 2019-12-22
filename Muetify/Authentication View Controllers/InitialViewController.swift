//
//  InitialViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/22/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            AuthService().setToken(token: token).getUser { [weak self] user, error in
                DispatchQueue.main.async {
                    if let navigationController = self?.storyboard?.instantiateViewController(withIdentifier: (error != nil) ? "auth" : "main") as? MainNavigationController {
                        navigationController.modalPresentationStyle = .fullScreen
                        self?.present(navigationController, animated: true, completion: nil)
                    }
                }
            }
        }
        
    }

}
