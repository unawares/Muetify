//
//  ItemsAlbumCollectionReusableView.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/9/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit


protocol FilterDelegate {
    
    func filterSelected(filterType: FilterType)
    
}


class ItemsHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var genresFilterView: SelectableCustomView!
    @IBOutlet weak var singersFilterView: SelectableCustomView!
    @IBOutlet weak var foldersFilterView: SelectableCustomView!
    
    @IBOutlet weak var genresFilterLabel: UILabel!
    @IBOutlet weak var singersFilterLabel: UILabel!
    @IBOutlet weak var foldersFilterLabel: UILabel!
        
    var selectedFilterType: FilterType?
    
    var delegate: FilterDelegate?
        
    func deselectFilter(filterType: FilterType) {
        switch filterType {
        case .FOLDERS:
            foldersFilterView.deselect()
            foldersFilterLabel.textColor = UIColor.init(red: 51/255, green: 1/255, blue: 140/255, alpha: 1)
        case .GENRES:
            genresFilterView.deselect()
            genresFilterLabel.textColor = UIColor.init(red: 51/255, green: 1/255, blue: 140/255, alpha: 1)
        case .SINGERS:
            singersFilterView.deselect()
            singersFilterLabel.textColor = UIColor.init(red: 51/255, green: 1/255, blue: 140/255, alpha: 1)
        }
    }
    
    func selectFilter(filterType: FilterType) {
        if let filterType = self.selectedFilterType {
            deselectFilter(filterType: filterType)
        }
        switch filterType {
        case .FOLDERS:
            foldersFilterView.select()
            foldersFilterLabel.textColor = .white
        case .GENRES:
            genresFilterView.select()
            genresFilterLabel.textColor = .white
        case .SINGERS:
            singersFilterView.select()
            singersFilterLabel.textColor = .white
        }
        selectedFilterType = filterType
    }
    
    override func awakeFromNib() {
    }
    
        
    @objc func foldersFilterClicked(sender: UITapGestureRecognizer) {
        selectFilter(filterType: .FOLDERS)
        delegate?.filterSelected(filterType: .FOLDERS)
    }
    
    @objc func genresFilterClicked(sender: UITapGestureRecognizer) {
        selectFilter(filterType: .GENRES)
        delegate?.filterSelected(filterType: .GENRES)
    }
    
    @objc func singersFilterClicked(sender: UITapGestureRecognizer) {
        selectFilter(filterType: .SINGERS)
        delegate?.filterSelected(filterType: .SINGERS)
    }
    
}
