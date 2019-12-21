//
//  ItemsContactTableViewCell.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/21/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class ItemsContactTableViewCell: UITableViewCell {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var avatarImageView: CircularImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
