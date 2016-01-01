//
//  ItemCell.swift
//  HorizontalFloatingHeaderLayout
//
//  Created by Diego Alberto Cruz Castillo on 12/31/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    //MARK: - Properties
    @IBOutlet weak var titleLabel:UILabel!
    
    //MARK: - Configure methods
    func configure(title title:String){
        func configureTitleLabel(){
            titleLabel.text = title
        }
        
        //
        configureTitleLabel()
    }
}
