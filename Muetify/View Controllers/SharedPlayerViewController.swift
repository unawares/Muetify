//
//  PlayerViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/9/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import AVKit


func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

class SharedPlayerViewController: UIViewController {
    
    static var shared: SharedPlayerViewController?
    var playerDelegate: MainPlayerDelegate?
    
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var timer: Timer!
    
    func sync() {
        playerButton.setBackgroundImage(
            (MainPlayer.shared.isPlaying ?
                UIImage.init(named: "pause_white") : UIImage.init(named: "play_white")),
            for: .normal)
        containerView.isHidden = MainPlayer.shared.source == nil
        logoImageView.isHidden = !containerView.isHidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        timer = Timer(timeInterval: 0.1,
                            target: self,
                            selector: #selector(update),
                            userInfo: nil,
                            repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedPlayerViewController.shared = self
    }
    
    @objc func update() {
        if let current = MainPlayer.shared.getCurrentTime()?.seconds, let total = MainPlayer.shared.getDuration()?.seconds {
            if (total != Double.nan) {
                let progress = max(0, min(Float(current / total), 1))
                progressView.progress = progress
            } else {
                progressView.progress = 0
            }
            let (_, m, s) = secondsToHoursMinutesSeconds(seconds: Int(current))
            timeLabel.text = String(format: "%02d:%02d", m, s)
            titleLabel.text = MainPlayer.shared.source?.getTitle()
            singerLabel.text = MainPlayer.shared.source?.getSingers()
        }
        sync()
    }
    
    @IBAction func playerButtonClicked(_ sender: UIButton) {
        MainPlayer.shared.isPlaying ? MainPlayer.shared.pause() : MainPlayer.shared.play()
        sync()
    }
    
    
    @IBAction func playerClicked(_ sender: Any) {
        if MainPlayer.shared.source != nil {
            if let navigationController = navigationController, let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "player") as? PlayerViewController {
                playerViewController.playerDelegate = playerDelegate
                playerViewController.song = MainPlayer.shared.source as? Song
                navigationController.show(playerViewController, sender: self)
            }
        }
    }
    
}
