//
//  DocumentCollectionViewCell.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

class DocumentCollectionViewCell: UICollectionViewCell {

    static let identifier = "DocumentCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
    }

}
