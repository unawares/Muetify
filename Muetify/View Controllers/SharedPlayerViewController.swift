//
//  PlayerViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/9/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import AVKit


class SharedPlayerViewController: UIViewController {
    
    //    private var audioFiles: Array<String> = [
    //        "song1"
    //    ]
    //    private var audioEngine: AVAudioEngine = AVAudioEngine()
    //    private var mixer: AVAudioMixerNode = AVAudioMixerNode()

    //    func play() {
    //        DispatchQueue.global(qos: .background).async {
    //            self.audioEngine.attach(self.mixer)
    //            self.audioEngine.connect(self.mixer, to: self.audioEngine.outputNode, format: nil)
    //
    //            try! self.audioEngine.start()
    //
    //            for audioFile in self.audioFiles {
    //                let audioPlayer = AVAudioPlayerNode()
    //
    //                self.audioEngine.attach(audioPlayer)
    //                self.audioEngine.connect(audioPlayer, to: self.mixer, format: nil)
    //
    //                let filePath = Bundle.main.path(forResource: audioFile, ofType: "mp3")!
    //                let fileUrl: URL = URL(fileURLWithPath: filePath)
    //
    //                let file : AVAudioFile = try! AVAudioFile.init(forReading: fileUrl.absoluteURL)
    //
    //                audioPlayer.scheduleFile(file, at: nil, completionHandler: nil)
    //                audioPlayer.play(at: nil)
    //
    //            }
    //
    //        }
    //    }
    
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var timer: Timer!
    
    func sync() {
        playerButton.setBackgroundImage(
            (MainPlayer.shared.isPlaying ?
                UIImage.init(named: "pause_white") : UIImage.init(named: "play_white")),
            for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sync()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainPlayer.shared.isBroadcasted = false
        MainBroadcaster.shared.broadcastUrl = URL(string: "rtmp://localhost:1935/live/lol")
        
        timer = Timer(timeInterval: 0.1,
                            target: self,
                            selector: #selector(update),
                            userInfo: nil,
                            repeats: true)
        RunLoop.current.add(timer, forMode: .common)
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
            singerLabel.text = MainPlayer.shared.source?.getSinger()
        }
        sync()
    }
    
    @IBAction func playerButtonClicked(_ sender: UIButton) {
        MainPlayer.shared.isPlaying ? MainPlayer.shared.pause() : MainPlayer.shared.play()
        sync()
    }
    
    
    @IBAction func playerClicked(_ sender: Any) {
        if let navigationController = navigationController, let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "player") as? PlayerViewController {
            navigationController.show(playerViewController, sender: self)
        }
    }
    
}
