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
                documentThumbnail.image = document!.pages.first?.thumbNailImage
            }
        }
    }
    
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var documentNameLabel: UILabel!
    @IBOutlet private weak var documentThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
        documentThumbnail.hero.id = Constant.HeroIdentifiers.imageView
    }

}
