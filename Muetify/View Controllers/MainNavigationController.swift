//
//  MainNavigationController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/17/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit


class MainNavigationController: UINavigationController {
    
    var tokenAuthData: TokenAuthData?

    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tokenAuthData = tokenAuthData {
            UserDefaults.standard.set(tokenAuthData.token, forKey: "token")
            SocketIOManager.shared.setToken(token: tokenAuthData.token)
        }
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            AppService().setToken(token: token).getUserFolders { [weak self] userFolderDatas, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showMessage(title: "Error", message: error.localizedDescription)
                    } else {
                        MySongs.shared.folders = userFolderDatas
                    }
                }
            }
        }
    }

}
