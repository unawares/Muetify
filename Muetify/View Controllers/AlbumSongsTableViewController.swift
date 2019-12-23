//
//  AlbumSongsTableViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/14/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class AlbumSongsTableViewController: UITableViewController, ItemSongDelegate, BroadcastPlayerDelegate, MainPlayerDelegate, CurrentContextDelegate {
    
    var token: String!
    var album: Album?
    var filterType: FilterType?
    var items: [Item] = []
    var task: URLSessionDataTask?
    
    var selectedIndexPath: IndexPath?
    
    var timer: Timer!
    
    override func viewWillAppear(_ animated: Bool) {
        timer = Timer(timeInterval: 0.1,
                            target: self,
                            selector: #selector(update),
                            userInfo: nil,
                            repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        tableView.reloadData()
        MainPlayer.shared.delegate = self
        MainPlayer.shared.currentContextDelegate = self
    }
    
    func changedSource() {
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func syncSongs(album: AlbumBase, songs: [SongData]) {
        items.removeAll()
        items.append(Header(title: album.getTitle(), description: nil))
        for song in songs {
            items.append(Song(
                id: song.pk,
                url: URL(string: song.media)!,
                title: song.title,
                singers: song.singers.joined(separator: ", "),
                duration: TimeInterval(song.duration),
                poster: URL(string: song.poster ?? ""),
                text: song.text
            ))
        }
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    func loadSongs() {
        if let album = album, let filterType = filterType {
            task?.cancel()
            refreshControl?.beginRefreshing()
            let appService = AppService().setToken(token: token)
            
            switch filterType {
            case .FOLDERS:
                appService.getFolderSongs(folder: album.albumBase.getKey()) { [weak self] songs, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.showMessage(title: "Error", message: error.localizedDescription)
                            self?.refreshControl?.endRefreshing()
                        }
                        self?.syncSongs(album: album.albumBase, songs: songs)
                    }
                }
            case .GENRES:
                appService.getGenreSongs(genre: album.albumBase.getKey()) { [weak self] songs, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.showMessage(title: "Error", message: error.localizedDescription)
                            self?.refreshControl?.endRefreshing()
                        }
                        self?.syncSongs(album: album.albumBase, songs: songs)
                    }
                }
            case .SINGERS:
                appService.getSingerSongs(singer: album.albumBase.getKey()) { [weak self] songs, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.showMessage(title: "Error", message: error.localizedDescription)
                            self?.refreshControl?.endRefreshing()
                        }
                        self?.syncSongs(album: album.albumBase, songs: songs)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        token = UserDefaults.standard.string(forKey: "token")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl!)
        loadSongs()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        var cell: UITableViewCell?
        
        switch item {
        case is Header:
            let header = item as! Header
            let itemView = tableView.dequeueReusableCell(withIdentifier: "items_header", for: indexPath) as! ItemsAlbumSongsHeaderTableViewCell
            itemView.titleLabel.text = header.title
            itemView.descriptionLabel.text = header.description
            itemView.closeButton.isHidden = indexPath.row != 0
            cell = itemView
        case is Song:
            let song = item as! Song
            let itemView = tableView.dequeueReusableCell(withIdentifier: "items_song", for: indexPath) as! ItemsSongTableViewCell
            let (_, m, s) = secondsToHoursMinutesSeconds(seconds: Int(song.duration))
            
            itemView.song = song
            
            itemView.indexPath = indexPath
            itemView.titleLabel.text = song.getTitle()
            itemView.singerLabel.text = song.getSingers()
            itemView.timeLabel.text = String(format: "%02d:%02d", m, s)
            itemView.isAttached = song.getId() == MainPlayer.shared.source?.getId()
            
            if itemView.isAttached && selectedIndexPath?.row != indexPath.row {
                startedPlay(indexPath: indexPath)
            }
            
            itemView.delegate = self
            
            cell = itemView
        default:
            cell = nil
        }
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let song = items[indexPath.row] as? Song {
            if let navigationController = navigationController, let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "player") as? PlayerViewController {
                playerViewController.playerDelegate = self
                playerViewController.song = song
                navigationController.show(playerViewController, sender: self)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc func update() {
        if let indexPath = selectedIndexPath, let song = items[indexPath.row] as? Song {
            if song.getId() == MainPlayer.shared.source?.getId() {
                if let cell = tableView.cellForRow(at: indexPath) as? ItemsSongTableViewCell {
                    if let current = MainPlayer.shared.getCurrentTime()?.seconds, let total = MainPlayer.shared.getDuration()?.seconds {
                        if (total != Double.nan) {
                            let progress = max(0, min(Float(current / total), 1))
                            cell.setProgress(progress: progress)
                        } else {
                            cell.setProgress(progress: 0)
                        }
                    }
                    cell.syncButton()
                }
            }
        }
    }
    
    func startedPlay(indexPath: IndexPath) {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            if let selectedIndexPath = selectedIndexPath {
                tableView.reloadRows(at: [selectedIndexPath, indexPath], with: .none)
            } else {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            selectedIndexPath = indexPath
            tableView.endUpdates()
        }
    }
    
    func playButtonClicked(indexPath: IndexPath) {
        startedPlay(indexPath: indexPath)
        MainPlayer.shared.playerDelegate = self
    }
    
    func onNext() {
        if let indexPath = selectedIndexPath {
            var index = indexPath.row + 1
            
            while (index < items.count && !(items[index] is Song)) {
                index += 1
            }
            
            if index >= items.count {
                index = 0
            }
            
            while (index < items.count && !(items[index] is Song)) {
                index += 1
            }
            
            if index < items.count {
                if let song = items[index] as? Song {
                    let indexPath = IndexPath(row: index, section: indexPath.section)
                    MainPlayer.shared.source = song
                    MainPlayer.shared.play()
                    startedPlay(indexPath: indexPath)
                }
            }
        }
    }
    
    func onPrevious() {
        if let indexPath = selectedIndexPath {
            var index = indexPath.row - 1
            
            while (index >= 0 && !(items[index] is Song)) {
                index -= 1
            }
            
            if index < 0 {
                index = items.count - 1
            }
            
            while (index >= 0 && !(items[index] is Song)) {
                index -= 1
            }
            
            if index >= 0 {
                if let song = items[index] as? Song {
                    let indexPath = IndexPath(row: index, section: indexPath.section)
                    MainPlayer.shared.source = song
                    MainPlayer.shared.play()
                    startedPlay(indexPath: indexPath)
                }
            }
        }
    }
    
    func onFinish() {
        tableView.reloadData()
    }
    
    @objc func refresh(sender:AnyObject) {
       loadSongs()
    }
    
}
