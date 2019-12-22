//
//  ItemsNetworkHeaderCollectionReusableView.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/22/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class ItemsNetworkHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var broadcastingSwitch: UISwitch!
    
    func syncSwitch() {
        broadcastingSwitch.isOn = MainPlayer.shared.isBroadcasted
    }
    
    @IBAction func toggle(_ sender: Any) {
        MainPlayer.shared.isBroadcasted = !MainPlayer.shared.isBroadcasted
    }
    
}
