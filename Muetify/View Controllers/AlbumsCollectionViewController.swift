//
//  AlbumsCollectionViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/8/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit


enum FilterType {
    
    case GENRES
    case SINGERS
    case FOLDERS
    
}

class AlbumsCollectionViewController: UICollectionViewController, FilterDelegate {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var token: String!
    var items: [AlbumBase] = []
    var selectedFilter: FilterType!
    var filterRequestTask: URLSessionDataTask?
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        token = UserDefaults.standard.string(forKey: "token")
        collectionView.delegate = self
        filterSelected(filterType: .GENRES)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        let itemView = collectionView.dequeueReusableCell(withReuseIdentifier: "items_album", for: indexPath) as? ItemsAlbumCollectionViewCell
        
        itemView?.titleLabel.text = item.getTitle()
        itemView?.countLabel.text = String(item.getCount())
        
        return itemView ?? UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "items_header",
                    for: indexPath
                ) as? ItemsHeaderCollectionReusableView else {
                    fatalError("Invalid view type")
                }

                headerView.delegate = self
                
                headerView.foldersFilterView.addGestureRecognizer(UITapGestureRecognizer(target: headerView, action: #selector(headerView.foldersFilterClicked)))
                headerView.genresFilterView.addGestureRecognizer(UITapGestureRecognizer(target: headerView, action: #selector(headerView.genresFilterClicked)))
                headerView.singersFilterView.addGestureRecognizer(UITapGestureRecognizer(target: headerView, action: #selector(headerView.singersFilterClicked)))
                
                headerView.selectFilter(filterType: selectedFilter)

                return headerView

            default:
                assert(false, "Invalid element type")
        }

    }
    
    func syncAlbums(albums: [AlbumBase]) {
        items = albums
        collectionView.reloadData()
        indicator.stopAnimating()
    }
    
    func filterSelected(filterType: FilterType) {
        let appService = AppService().setToken(token: token)
        filterRequestTask?.cancel()
        items.removeAll()
        collectionView.reloadData()
        indicator.startAnimating()
        
        switch filterType {
        case .FOLDERS:
            filterRequestTask = appService.getUserFolders { [weak self] userFolderDatas, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showMessage(title: "Error", message: error.localizedDescription)
                        self?.indicator.stopAnimating()
                    } else {
                        self?.syncAlbums(albums: userFolderDatas)
                    }
                }
            }
        case .GENRES:
            filterRequestTask = appService.getUserGenres { [weak self] userGenreDatas, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showMessage(title: "Error", message: error.localizedDescription)
                        self?.indicator.stopAnimating()
                    } else {
                         self?.syncAlbums(albums: userGenreDatas)
                    }
                }
            }
        case .SINGERS:
            filterRequestTask = appService.getUserSingers { [weak self] userSingerDatas, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showMessage(title: "Error", message: error.localizedDescription)
                        self?.indicator.stopAnimating()
                    } else {
                         self?.syncAlbums(albums: userSingerDatas)
                    }
                }
            }
        }
        
        selectedFilter = filterType
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let albumSongsTableViewController = segue.destination as? AlbumSongsTableViewController,
            let indexPath = collectionView.indexPathsForSelectedItems?.first {
            albumSongsTableViewController.album = items[indexPath.row]
            albumSongsTableViewController.filterType = selectedFilter
        }
    }
    
}


extension AlbumsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
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

}


@IBDesignable
class SelectableCustomView: CustomView {

    func select() {
        backgroundColor = UIColor.init(red: 51/255, green: 1/255, blue: 140/255, alpha: 1)
        
    }
    
    func deselect() {
        backgroundColor = nil
    }

}
