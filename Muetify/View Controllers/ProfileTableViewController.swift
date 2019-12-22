//
//  ProfileTableViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/21/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController, ItemSongDelegate, BroadcastPlayerDelegate {

    var token: String!
    var friend: Contact!
    
    var items: [Item] = []
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    func changedSource() {
        tableView.reloadData()
    }
    
    func foldItems(songReferences: [SongReferenceData]) {
        var foldedSongs: [FolderData: [Song]] = [:]
        var unfoldedSongs: [Song] = []
        
        for songReference in songReferences {
            if let songData = songReference.songData {
                
                let song = Song(
                    id: songData.pk,
                    url: URL(string: songData.media)!,
                    title: songData.title,
                    singers: songData.singers.joined(separator: ", "),
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
        items.append(ContactHeader(
            fullName: "\(friend.firstName) \(friend.lastName)",
            phoneNumber: friend.phoneNumber,
            avatar: friend.avatar
        ))
        
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
                description: nil
            ))
            
            for song in unfoldedSongs {
                items.append(song)
            }
            
        }
        
        if items.count == 1 {
            items.append(Header(
                title: "Пусто",
                description: "На данный момент ваш контакт не имеет никаких песен."
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
        AppService().setToken(token: token).getFriendSongs(friendId: friend.id) { [weak self] songReference, error in
            DispatchQueue.main.async {
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
        case is ContactHeader:
            
            let header = item as! ContactHeader
            let itemView = tableView.dequeueReusableCell(withIdentifier: "items_contact_header", for: indexPath) as! ItemsContactHeaderTableViewCell
            itemView.fullNameLabel.text = header.fullName
            itemView.phoneNumberLabel.text = header.phoneNumber
            cell = itemView
            
        case is Header:
            
            let header = item as! Header
            let itemView = tableView.dequeueReusableCell(withIdentifier: "items_header", for: indexPath) as! ItemsHeaderTableViewCell
            itemView.titleLabel.text = header.title
            itemView.descriptionLabel.text = header.description
            itemView.settingsButton.isHidden = true
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
                playButtonClicked(indexPath: indexPath)
            }

            itemView.delegate = self
            
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
    
    func playButtonClicked(indexPath: IndexPath) {
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
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func refresh(sender:AnyObject) {
       loadSongs()
    }

}
