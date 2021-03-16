//
//  DocumentCollectionViewCell.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

class DocumentCollectionViewCell: UICollectionViewCell {

    static let identifier = "DocumentCollectionViewCell"
    
    var document: Document? {
        didSet {
            if document != nil {
                documentNameLabel.text = document!.name
                documentThumbnail.image = document!.thumbNailImage
            }
        }
    }
    
    @IBOutlet private weak var documentNameLabel: UILabel!
    @IBOutlet private weak var documentThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
    }

}
