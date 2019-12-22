//
//  NetworkViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/10/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import AVKit
import SocketIO

class NetworkCollecitonViewController: UICollectionViewController, SocketIOClientDelegate {
    
    var token: String!
    
    var broadcasts: [Broadcast] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        token = UserDefaults.standard.string(forKey: "token")
        self.collectionView.delegate = self
        
        SocketIOManager.shared.delegate = self
        SocketIOManager.shared.setToken(token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJkYXRhIjoie1widXVpZFwiOiBcIjM5OTkyYzBmYTRkODRlZTdiNDg1ZjNkMDkxODU4MDM3XCIsIFwiY3JlYXRlZFwiOiBcIjIwMTktMTItMjFUMTQ6NDQ6MjMuMTgzXCIsIFwicGhvbmVfbnVtYmVyXCI6IFwiKzc3MDgxMzMwOTMxXCJ9In0.WfF66MvjYnVP4I5EznbQ2ellqkoIZaVVNEX1xs8DJvo")
    }

    
    func isReady() {
        SocketIOManager.shared.broadcasts()
    }
    
    func broadcasts(broadcasts: [Broadcast]) {
        self.broadcasts = broadcasts
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if SocketIOManager.shared.isReady {
            SocketIOManager.shared.broadcasts()
        }
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return broadcasts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "items_channel", for: indexPath)
        
        let broadcast = broadcasts[indexPath.row]
        
        if let channelItemView = cell as? ItemsChannelCollectionViewCell {
            
            channelItemView.fullNameLabel.text = "\(broadcast.user.firstName) \(broadcast.user.lastName)"
            channelItemView.phoneNumberLabel.text = broadcast.user.phoneNumber
            
            if let urlString = broadcast.user.avatar, let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    if let data = try? Data(contentsOf: url) {
                        channelItemView.avatarImageView.image = UIImage(data: data)
                    }
                }
            }
            
            if let urlString = broadcast.data?["poster"] as? String, let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    if let data = try? Data(contentsOf: url) {
                        channelItemView.backgroundImageView.image = UIImage(data: data)
                    }
                }
            }
            
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "items_header",
                    for: indexPath) as? ItemsNetworkHeaderCollectionReusableView else {
                        fatalError("Invalid view type")
                    }
                headerView.syncSwitch()
        
        return headerView
        default:
        assert(false, "Invalid element type")
        }
    }
    
}


extension NetworkCollecitonViewController: UICollectionViewDelegateFlowLayout {
    
    override func viewWillLayoutSubviews() {
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        let spacing = CGFloat(16)
        
        var itemsInOneLine: CGFloat = 0
        let padding = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        
        switch orientation {
        
        case .landscapeLeft:
            fallthrough
        case .landscapeRight:
            itemsInOneLine = 4
        case .portrait:
            fallthrough
        default:
            itemsInOneLine = 2
        }
        
        let width = (collectionView.frame.width - padding.left - padding.right) - spacing * CGFloat(itemsInOneLine - 1)
        
        flow.sectionInset = padding
        flow.itemSize = CGSize(width: floor(width / itemsInOneLine), height: width / itemsInOneLine)
        flow.minimumLineSpacing = spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }

}
