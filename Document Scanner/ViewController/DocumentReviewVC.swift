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
    
    weak var delegate: DocumentReviewVCDelegate?
    var document: Document?
    
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var shareButton: FooterButton!
    @IBOutlet private weak var editButton: FooterButton!
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _setupView()
    }

    private func _setupView() {
        guard  let document = document else {
            fatalError("ERROR: document is not set")
        }
        configureUI(title: document.name)
        documentImageView.hero.id = document.id.uuidString
        documentImageView.image = document.pages.first?.editedImage
    }
    
    private func _setupFooterView() {
        footerView?.hero.id = Constant.HeroIdentifiers.footerIdentifier
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
