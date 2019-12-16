//
//  ProfileContactsTableViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/16/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class ProfileContactsTableViewController: UITableViewController {
    
    var items: [Item] = [
        Header(
            title: "Мои контакты",
            description: "Стараемся максимально собрать на казахском"
        ),
        Contact(
            fullName: "Theodore Teddy",
            statusInfo: "Hello Google"
        ),
        Contact(
            fullName: "Theodore Teddy",
            statusInfo: "Hello Google"
        ),
        Contact(
            fullName: "Theodore Teddy",
            statusInfo: "Hello Google"
        ),
        Contact(
            fullName: "Theodore Teddy",
            statusInfo: "Hello Google"
        ),
        Contact(
            fullName: "Theodore Teddy",
            statusInfo: "Hello Google"
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
        case is Contact:
            cell = tableView.dequeueReusableCell(withIdentifier: "items_contact", for: indexPath)
        default:
            cell = nil
        }
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
