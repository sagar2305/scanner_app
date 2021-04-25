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
                documentCreationDate.text = "\(document!.creationDate)"
                hero.id = document!.id.uuidString
            }
        }
    }
    
    @IBOutlet private weak var documentNameLabel: UILabel!
    @IBOutlet private weak var documentCreationDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _configureCell()
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.cardBackground.cgColor
    }
    
    private func _configureCell() {
        documentNameLabel.configure(with: UIFont.font(.avenirRegular, style: .body))
        documentCreationDate.configure(with: UIFont.font(.avenirRegular, style: .footnote))
    }

}
