//
//  SongsTableViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/7/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class SongsTableViewController: UITableViewController {
    
    var items: [Item] = [
        Header(
            title: "Песни на казахском",
            description: "Стараемся максимально собрать на казахском"
        ),
        Song(
            url: Bundle.main.url(forResource: "song2", withExtension: ".mp3")!,
            title: "Мың есе",
            singer: "Мирас Жугунусов",
            duration: 3 * 60 + 50
        ),
        Song(
            url: Bundle.main.url(forResource: "song1", withExtension: ".mp3")!,
            title: "Сенімен",
            singer: "Мирас Жугунусов",
            duration: 2 * 60 + 48
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
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
            cell = tableView.dequeueReusableCell(withIdentifier: "items_header", for: indexPath)
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
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
