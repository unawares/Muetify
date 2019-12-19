//
//  AlbumSongsTableViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/14/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class AlbumSongsTableViewController: UITableViewController {
    
    var token: String!
    var album: AlbumBase?
    var filterType: FilterType?
    var items: [Item] = []
    var task: URLSessionDataTask?
    
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
                singer: song.singers.joined(separator: ", "),
                duration: TimeInterval(song.duration)
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
                appService.getFolderSongs(folder: album.getKey()) { [weak self] songs, error in
                    DispatchQueue.main.sync {
                        if let error = error {
                            self?.showMessage(title: "Error", message: error.localizedDescription)
                            self?.refreshControl?.endRefreshing()
                        }
                        self?.syncSongs(album: album, songs: songs)
                    }
                }
            case .GENRES:
                appService.getGenreSongs(genre: album.getKey()) { [weak self] songs, error in
                    DispatchQueue.main.sync {
                        if let error = error {
                            self?.showMessage(title: "Error", message: error.localizedDescription)
                            self?.refreshControl?.endRefreshing()
                        }
                        self?.syncSongs(album: album, songs: songs)
                    }
                }
            case .SINGERS:
                appService.getSingerSongs(singer: album.getKey()) { [weak self] songs, error in
                    DispatchQueue.main.sync {
                        if let error = error {
                            self?.showMessage(title: "Error", message: error.localizedDescription)
                            self?.refreshControl?.endRefreshing()
                        }
                        self?.syncSongs(album: album, songs: songs)
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
            itemView.titleLabel.text = song.getTitle()
            itemView.singerLabel.text = song.getSinger()
            itemView.timeLabel.text = String(format: "%02d:%02d", m, s)
            cell = itemView
        default:
            cell = nil
        }
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items[indexPath.row] is Song {
            if let navigationController = navigationController, let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "player") as? PlayerViewController {
                navigationController.show(playerViewController, sender: self)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func refresh(sender:AnyObject) {
       loadSongs()
    }
    
    
}