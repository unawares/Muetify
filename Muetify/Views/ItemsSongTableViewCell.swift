//
//  ItemsSongTableViewCell.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/14/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class ItemsSongTableViewCell: UITableViewCell {
    
    var song: Song!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        MainPlayer.shared.source = song
        MainPlayer.shared.play()
    }
    
}
