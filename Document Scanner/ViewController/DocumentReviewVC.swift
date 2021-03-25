//
//  DocumentReviewVC.swift
//  Document Scanner
//
//  Created by Sandesh on 17/03/21.
//

import UIKit

protocol DocumentReviewVCDelegate: class {
    func documentReviewVC(edit document: Document, controller: DocumentReviewVC)
    func documentReviewVC(_ share: Document, shareAs: DocumentReviewVC.ShareOptions, controller: DocumentReviewVC)
}

class DocumentReviewVC: DocumentScannerViewController {
    
    enum ShareOptions {
        case pdf
        case jpg
    }
    
    private var _footerCornerRadius: CGFloat = 8
    
    @IBOutlet private weak var documentImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var documentImageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var footerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var footerViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var footerViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: DocumentReviewVCDelegate?
    var document: Document?
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var documentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        _setupView()
        _setupFooterView()
    }

    private func _setupView() {
        guard  let document = document else {
            fatalError("ERROR: document is not set")
        }
        configureUI(title: document.name)
        documentImageView.image = document.pages.first?.editedImage
        
        if UIDevice.current.hasNotch {
            documentImageViewLeadingConstraint.constant = 8
            documentImageViewTrailingConstraint.constant = 8
        } else {
            documentImageViewLeadingConstraint.constant = 0
            documentImageViewTrailingConstraint.constant = 0
        }
    }
    
    private func _setupFooterView() {
        footerView?.hero.id = Constant.HeroIdentifiers.footerIdentifier
        footerView?.clipsToBounds = true
        if UIDevice.current.hasNotch {
            footerView?.layer.cornerRadius = _footerCornerRadius
            footerViewLeadingConstraint?.constant = 8
            footerViewTrailingConstraint?.constant = 8
        } else {
            footerView?.layer.cornerRadius = 0
            footerViewLeadingConstraint?.constant = 0
            footerViewTrailingConstraint?.constant = 0
            footerViewBottomConstraint?.constant = 0
        }
    }
    
    @IBAction func didTapEdit(_ sender: UIButton) {
        delegate?.documentReviewVC(edit: document!, controller: self)
    }
    
    @IBAction func didTapShare(_ sender: UIButton) {
        let actionSheetController = UIAlertController(title: "Share document as", message: nil, preferredStyle: .actionSheet)
        actionSheetController.addAction(UIAlertAction(title: "PDF", style: .default, handler: { _ in
            self.shareDocument(shareAs: .pdf)
        }))
        actionSheetController.addAction(UIAlertAction(title: "Picture", style: .default, handler: { _ in
            self.shareDocument(shareAs: .jpg)
        }))
        
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
        
        present(actionSheetController, animated: true)
    }
    
    func shareDocument( shareAs: ShareOptions) {
        delegate?.documentReviewVC(document!, shareAs: shareAs, controller: self)
    }
}
