//
//  CollectionViewController.swift
//  HorizontalFloatingHeaderLayout
//
//  Created by Diego Alberto Cruz Castillo on 12/31/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import HorizontalFloatingHeaderLayout

class CollectionViewController: UICollectionViewController,HorizontalFloatingHeaderLayoutDelegate {

    //MARK: - Configure methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure(){
        func configureCollectionView(){
            collectionView?.contentInset = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        
        func configureHeaderCell(){
            let headerNib = UINib(nibName: "HeaderView",bundle: nil)
            collectionView?.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
        }
        
        //
        configureCollectionView()
        configureHeaderCell()
    }

    // MARK: - UICollectionView methods
    //MARK: Datasource
    //Number of Sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }

    //Number of Items
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 34
    }

    //Cells
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
    
    //Headers
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
        return header
    }

    //MARK: Delegate (HorizontalFloatingHeaderDelegate)
    //Item Size
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderItemSizeAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:48, height: 48)
    }
    
    //Header Size
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSizeAt section: Int) -> CGSize {
        return CGSize(width:160, height:30)
    }
    
    //Item Spacing
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderItemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    //Line Spacing
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderColumnSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    //Section Insets
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSectionInsetAt section: Int) -> UIEdgeInsets {
        switch section{
        case 0:
            return UIEdgeInsetsMake(8, 0, 0, 0)
        default:
            return UIEdgeInsetsMake(8, 8, 0, 0)
        }
    }
}
