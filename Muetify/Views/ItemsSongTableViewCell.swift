//
//  ItemsSongTableViewCell.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/14/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit



protocol ItemSongDelegate {
    
    func playButtonClicked(indexPath: IndexPath)
    
}

class ItemsSongTableViewCell: UITableViewCell {
    
    var song: Song!
    var indexPath: IndexPath?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playerButton: UIButton!
    
    var delegate: ItemSongDelegate?
    
    var isAttached: Bool = false {
        
        didSet {
            backgroundColor = isAttached ? UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1) : nil
            progressView.isHidden = !isAttached
            syncButton()
        }
        
    }
    
    func syncButton() {
        if isAttached {
            playerButton.setBackgroundImage(
                (MainPlayer.shared.isPlaying ?
                    UIImage.init(named: "pause") : UIImage.init(named: "play")),
                for: .normal)
        } else {
            playerButton.setBackgroundImage(UIImage.init(named: "play"), for: .normal)
        }
    }
    
    func setProgress(progress: Float) {
        progressView.progress = progress
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        if isAttached {
            MainPlayer.shared.isPlaying ? MainPlayer.shared.pause() : MainPlayer.shared.play()
            syncButton()
        } else {
            print(song.getUrl())
            MainPlayer.shared.source = song
            MainPlayer.shared.play()
            if let indexPath = indexPath {
                delegate?.playButtonClicked(indexPath: indexPath)
            }
        }
    }
    
}
