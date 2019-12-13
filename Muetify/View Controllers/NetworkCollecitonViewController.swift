//
//  NetworkViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/10/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import AVKit
import mobileffmpeg

class NetworkCollecitonViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "items_channel", for: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        guard
          let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "items_header",
            for: indexPath) as? ItemsHeaderCollectionReusableView
          else {
            fatalError("Invalid view type")
        }
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
