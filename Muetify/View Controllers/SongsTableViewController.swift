//
//  SongsTableViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/7/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import AVKit

class SongsTableViewController: UITableViewController {
        
    var token: String!
    
    var items: [Item] = []
    
    func foldItems(songReferences: [SongReferenceData]) {
        var foldedSongs: [FolderData: [Song]] = [:]
        var unfoldedSongs: [Song] = []
        
        for songReference in songReferences {
            if let songData = songReference.songData {
                
                let song = Song(
                    id: songData.pk,
                    url: URL(string: songData.media)!,
                    title: songData.title,
                    singer: songData.singers.joined(separator: ", "),
                    duration: TimeInterval(songData.duration)
                )
                
                if let folder = songReference.folderData {
                    if foldedSongs[folder] == nil {
                        foldedSongs[folder] = []
                    }
                    foldedSongs[folder]?.append(song)
                } else {
                    unfoldedSongs.append(song)
                }
                
            }
        }
        
        items.removeAll()
        
        for folder in Array(foldedSongs.keys).sorted(by: <) {
            items.append(Header(
                title: folder.title,
                description: folder.description
            ))
            for song in foldedSongs[folder]! {
                items.append(song)
            }
        }
        
        if unfoldedSongs.count > 0 {
            
            items.append(Header(
                title: "Другие",
                description: "Не упорядочные песни."
            ))
            
            for song in unfoldedSongs {
                items.append(song)
            }
            
        }
        
        if items.count == 0 {
            items.append(Header(
                title: "Пусто",
                description: "Добавьте песни."
            ))
        }
        
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadSongs() {
        refreshControl?.beginRefreshing()
        AppService().setToken(token: token).getUserSongs { [weak self] songReference, error in
            DispatchQueue.main.sync {
                if let error = error {
                    self?.showMessage(title: "Error", message: error.localizedDescription)
                    self?.refreshControl?.endRefreshing()
                } else {
                    self?.foldItems(songReferences: songReference)
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
            let itemView = tableView.dequeueReusableCell(withIdentifier: "items_header", for: indexPath) as! ItemsHeaderTableViewCell
            itemView.titleLabel.text = header.title
            itemView.descriptionLabel.text = header.description
            itemView.settingsButton.isHidden = indexPath.row != 0
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
    
    @objc func refresh(sender:AnyObject) {
       loadSongs()
    }

}
