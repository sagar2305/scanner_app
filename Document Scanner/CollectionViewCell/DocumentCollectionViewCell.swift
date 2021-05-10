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
                previewImageView.image = document!.pages.first?.thumbNailImage
                previewImageView.hero.id = document!.id.uuidString
            }
        }
    }
    
    @IBOutlet private weak var documentNameLabel: UILabel!
    @IBOutlet private weak var previewImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        _configureCell()
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.shadow.cgColor
    }
    
    private func _configureCell() {
        documentNameLabel.configure(with: UIFont.font(.avenirRegular, style: .body))
       
    }

}
