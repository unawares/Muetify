//
//  ItemsHeaderTableViewCell.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/18/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class ItemsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
