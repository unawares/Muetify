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
    var items: [Item] = []
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
        if let filterType = selectedFilter {
            filterSelected(filterType: filterType)
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell?
        
        let item = items[indexPath.row]
        
        switch item {
        case is Album:
            let album = item as! Album
            let itemView = collectionView.dequeueReusableCell(withReuseIdentifier: "items_album", for: indexPath) as? ItemsAlbumCollectionViewCell
            
            itemView?.titleLabel.text = album.albumBase.getTitle()
            itemView?.countLabel.text = String(album.albumBase.getCount())
            
            if selectedFilter == .FOLDERS {
                let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                itemView?.contentView.addGestureRecognizer(lpgr)
            }
            
            cell = itemView
        case is Add:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "items_add", for: indexPath)
        default:
            break
        }

        return cell ?? UICollectionViewCell()
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
        items.removeAll()
        for albumBase in albums {
            items.append(Album(albumBase: albumBase))
        }
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
                        self?.items.removeAll()
                        for albumBase in userFolderDatas {
                            self?.items.append(Album(albumBase: albumBase))
                        }
                        self?.items.append(Add())
                        self?.collectionView.reloadData()
                        self?.indicator.stopAnimating()
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if items[indexPath.row] is Add {
            showCreateForm()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let albumSongsTableViewController = segue.destination as? AlbumSongsTableViewController,
            let indexPath = collectionView.indexPathsForSelectedItems?.first {
            if let album = items[indexPath.row] as? Album {
                albumSongsTableViewController.album = album
                albumSongsTableViewController.filterType = selectedFilter
            }
        }
    }
    
    @IBAction func settingsButtonClicked(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "settings") as? SettingsViewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    func showCreateForm() {
        let alertController = UIAlertController(title: "Добавить новый альбом", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Добавить", style: .default) { (_) in
            if let titleField = alertController.textFields?[0], let title = titleField.text,
                let descriptionField = alertController.textFields?[1], let description = descriptionField.text {
                if title.count > 0 && description.count > 0 {
                    
                    AppService().setToken(token: self.token).createFolder(folder: UserFolderPostData(
                        title: title, description: description)) { [weak self] folder, error in
                            DispatchQueue.main.async {
                                if let error = error {
                                    self?.showMessage(title: "Ошибка", message: error.localizedDescription)
                                } else {
                                    self?.filterSelected(filterType: self?.selectedFilter ?? .FOLDERS)
                                }
                            }
                    }
                    
                } else {
                    self.showMessage(title: "Неправильные данные", message: "Пожалуйстве заполните формы правильно.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Название"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Описание"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showUpdateForm(album: Album) {
        if let folderData = album.albumBase as? UserFolderData {
            let alertController = UIAlertController(title: "Изменить альбом", message: nil, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Изменить", style: .default) { (_) in
                if let titleField = alertController.textFields?[0], let title = titleField.text,
                    let descriptionField = alertController.textFields?[1], let description = descriptionField.text {
                    if title.count > 0 && description.count > 0 {
                        
                        AppService().setToken(token: self.token).updateFolder(folderKey: album.albumBase.getKey(), toFolder: UserFolderPostData(
                            title: title, description: description)) { [weak self] folder, error in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        self?.showMessage(title: "Ошибка", message: error.localizedDescription)
                                    } else {
                                        self?.filterSelected(filterType: self?.selectedFilter ?? .FOLDERS)
                                    }
                                }
                        }
                        
                    } else {
                        self.showMessage(title: "Неправильные данные", message: "Пожалуйстве заполните формы правильно.")
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in }
            alertController.addTextField { (textField) in
                textField.placeholder = "Название"
                textField.text = folderData.title
            }
            alertController.addTextField { (textField) in
                textField.placeholder = "Описание"
                textField.text = folderData.description
            }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showActionsFor(album: Album) {
        let alert = UIAlertController(title: album.albumBase.getTitle(), message: "Выберите действие", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Изменить", style: .default, handler: { (_) in
            self.showUpdateForm(album: album)
        }))

        alert.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { (_) in
            AppService().setToken(token: self.token).removeFolder(folderKey: album.albumBase.getKey()) { [weak self] error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.showMessage(title: "Ошибка", message: error.localizedDescription)
                        } else {
                            self?.filterSelected(filterType: self?.selectedFilter ?? .FOLDERS)
                        }
                    }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        let p = gesture.location(in: self.collectionView)
        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            if let album = items[indexPath.row] as? Album {
                showActionsFor(album: album)
            }
        } else {
            print("couldn't find index path")
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
