//
//  ContactsTableViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/13/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {

    var token: String!
    
    var items: [Item] = []
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func initContacts(contacts: [UserData]) {
        items.removeAll()
        items.append(Header(title: "Мои контакты", description: nil))
        for contact in contacts {
            
        }
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    func loadContacts() {
        refreshControl?.beginRefreshing()
        AppService().setToken(token: token).getContacts { [weak self] contacts, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showMessage(title: "Error", message: error.localizedDescription)
                    self?.refreshControl?.endRefreshing()
                } else {
                    self?.initContacts(contacts: contacts)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        token = UserDefaults.standard.string(forKey: "token")
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl!)
        
        loadContacts()
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

    @objc func refresh(sender:AnyObject) {
       loadContacts()
    }
    
}
