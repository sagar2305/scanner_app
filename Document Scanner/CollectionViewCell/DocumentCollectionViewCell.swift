//
//  DocumentCollectionViewCell.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit
import SwipeCellKit

class DocumentCollectionViewCell: SwipeCollectionViewCell {

    static let identifier = "DocumentCollectionViewCell"
    
    var document: Document? {
        didSet {
            if document != nil {
                documentNameLabel.text = document!.name
                previewImageView.image = document!.pages.first?.thumbNailImage
                previewImageView.hero.id = document!.id
                documentDetailLabel.text = document!.details
            }
        }
    }
    
    @IBOutlet private weak var documentNameLabel: UILabel!
    @IBOutlet private weak var documentDetailLabel: UILabel!
    @IBOutlet private weak var previewImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        _configureCell()
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.shadow.cgColor
        documentNameLabel.configure(with: UIFont.font(.avenirMedium, style: .body))
        documentDetailLabel.configure(with: UIFont.font(.avenirRegular, style: .footnote))
    }
    
    private func _configureCell() {
        documentNameLabel.configure(with: UIFont.font(.avenirRegular, style: .body))
       
    }

}
