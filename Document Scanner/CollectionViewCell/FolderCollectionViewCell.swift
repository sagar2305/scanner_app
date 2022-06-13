//
//  FolderViewCell.swift
//  Document Scanner
//
//  Created by Sandesh on 12/08/21.
//

import UIKit

protocol FolderCollectionViewCellDelegate: AnyObject {
    func folderCollectionViewCell(_ folderCollectionViewCell: FolderCollectionViewCell, moreButtonTappedFor folder: Folder)
}

class FolderCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "FolderCollectionViewCell"
    
    weak var delegate: FolderCollectionViewCellDelegate?
    
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

    @IBAction func didTapMoreButton(_ sender: UIButton) {
        if let delegate = delegate,
           let folder = folder {
            delegate.folderCollectionViewCell(self, moreButtonTappedFor: folder)
        }
    }
}
