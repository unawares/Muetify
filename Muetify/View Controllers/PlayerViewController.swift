//
//  PlayerViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/13/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    
    var song: Song? {
        
        didSet {
            isSynchronized = MainPlayer.shared.source?.getId() == song?.getId()
            if isReady {
                titleLabel.text = song?.getTitle()
                singerLabel.text = song?.getSingers()
            }
        }
        
    }

    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var playerButton: CustomButton!
    @IBOutlet weak var previousButton: CustomButton!
    @IBOutlet weak var nextButton: CustomButton!
    @IBOutlet weak var broadcastButton: UIButton!
    @IBOutlet weak var progressMaintainerView: CustomView!
    @IBOutlet weak var progressView: CustomView!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    var playerDelegate: MainPlayerDelegate?
    
    var timer: Timer!
    var isDragging = false
    var isSynchronized = false
    var isReady = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = song?.getTitle()
        singerLabel.text = song?.getSingers()
        isReady = true
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
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func sync() {
        playerButton.setBackgroundImage(
            (MainPlayer.shared.isPlaying ?
                UIImage.init(named: "pause_music") : UIImage.init(named: "play_music")),
            for: .normal)
        broadcastButton.alpha = MainPlayer.shared.isBroadcasted ? 1 : 0.3
    }
    
    func setProgress(progress: Float) {
        progressWidthConstraint.constant = progressMaintainerView.frame.width * CGFloat(progress)
    }
    
    @objc func update() {
        if isSynchronized {
            if !isDragging {
                if let current = MainPlayer.shared.getCurrentTime()?.seconds, let total = MainPlayer.shared.getDuration()?.seconds {
                        if (total != Double.nan) {
                            setProgress(progress: max(0, min(Float(current / total), 1)))
                        } else {
                            setProgress(progress: 0)
                        }

                        titleLabel.text = MainPlayer.shared.source?.getTitle()
                        singerLabel.text = MainPlayer.shared.source?.getSingers()
                    }
                sync()
            }
        }
    }
    
    @IBAction func playerButtonClicked(_ sender: UIButton) {
        if isSynchronized {
            MainPlayer.shared.isPlaying ? MainPlayer.shared.pause() : MainPlayer.shared.play()
            sync()
        } else {
            MainPlayer.shared.source = song
            MainPlayer.shared.play()
            sync()
            isSynchronized = true
        }
    }
    
    
    @IBAction func panGestureForSeek(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            isDragging = true
        case .changed:
            let progress = Float(
                max(0, min(
                    progressMaintainerView.frame.width,
                    sender.location(in: progressMaintainerView).x
                )) / progressMaintainerView.frame.width
            )
            setProgress(progress: progress)
            MainPlayer.shared.seek(padding: Double(progress) * (MainPlayer.shared.getDuration()?.seconds ?? 0))
        case .ended:
            isDragging = false
        default:
            break
        }
        
    }
    
    @IBAction func tapGestureForSeek(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .began:
            isDragging = true
        case .ended:
            let progress = Float(
                max(0, min(
                    progressMaintainerView.frame.width,
                    sender.location(in: progressMaintainerView).x
                )) / progressMaintainerView.frame.width
            )
            setProgress(progress: progress)
            MainPlayer.shared.seek(padding: Double(progress) * (MainPlayer.shared.getDuration()?.seconds ?? 0))
            isDragging = false
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let songTextViewController = segue.destination as? SongTextViewController {
            songTextViewController.song = song
        }
    }
    
    @IBAction func previousButtonClicked(_ sender: Any) {
        playerDelegate?.onPrevious()
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        playerDelegate?.onNext()
    }
    
    @IBAction func broadcastButtonClicked(_ sender: Any) {
        MainPlayer.shared.isBroadcasted = !MainPlayer.shared.isBroadcasted
        sync()
    }
    
    @IBAction func settingsButtonClicked(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "settings") as? SettingsViewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}
