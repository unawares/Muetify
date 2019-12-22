//
//  SongTextViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/23/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class SongTextViewController: UIViewController {

    var song: Song?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singersLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let song = song {
            titleLabel.text = song.getTitle()
            singersLabel.text = song.getSingers()
            textLabel.text = song.getText()
        }
        
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
