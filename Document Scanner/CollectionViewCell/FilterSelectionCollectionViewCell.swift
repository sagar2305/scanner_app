//
//  FilterSelectionCollectionViewCell.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import UIKit

class FilterSelectionCollectionViewCell: UICollectionViewCell {

    var filterIcon: Icons!
    
    @IBOutlet private weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
    }

}
