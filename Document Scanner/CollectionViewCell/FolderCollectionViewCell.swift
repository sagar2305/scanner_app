//
//  FolderViewCell.swift
//  Document Scanner
//
//  Created by Sandesh on 12/08/21.
//

import UIKit

class FolderCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "FolderCollectionViewCell"
    
    @IBOutlet private weak var folderNameLabel: UILabel!
    @IBOutlet private weak var documentCountsLabel: UILabel!
    @IBOutlet private weak var moreOptionButton: UIButton!
    
    var folder: Folder? {
        didSet {
            guard let folder = folder else { return }
            folderNameLabel.text = folder.name
            documentCountsLabel.text = "\(folder.documetCount)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupViews()
    }
    
    private func _setupViews() {
        folderNameLabel.configure(with: UIFont.font(.DMSansBold, style: .body))
        documentCountsLabel.configure(with: UIFont.font(.DMSansMedium, style: .footnote))
    }

}
