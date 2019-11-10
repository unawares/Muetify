//
//  PlayerViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/9/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import AVKit


class PlayerViewController: UIViewController {
    
    private var audioFiles: Array<String> = [
        "song1"
    ]
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var mixer: AVAudioMixerNode = AVAudioMixerNode()
    
    func play() {
        DispatchQueue.global(qos: .background).async {
            self.audioEngine.attach(self.mixer)
            self.audioEngine.connect(self.mixer, to: self.audioEngine.outputNode, format: nil)

            try! self.audioEngine.start()

            for audioFile in self.audioFiles {
                let audioPlayer = AVAudioPlayerNode()
                
                self.audioEngine.attach(audioPlayer)
                self.audioEngine.connect(audioPlayer, to: self.mixer, format: nil)
                
                let filePath = Bundle.main.path(forResource: audioFile, ofType: "mp3")!
                let fileUrl: URL = URL(fileURLWithPath: filePath)

                let file : AVAudioFile = try! AVAudioFile.init(forReading: fileUrl.absoluteURL)

                audioPlayer.scheduleFile(file, at: nil, completionHandler: nil)
                audioPlayer.play(at: nil)
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        play()
    }

}
