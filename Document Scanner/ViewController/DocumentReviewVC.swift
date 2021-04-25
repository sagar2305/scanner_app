//
//  DocumentReviewVC.swift
//  Document Scanner
//
//  Created by Sandesh on 17/03/21.
//

import UIKit
import SnapKit


protocol DocumentReviewVCDelegate: class {
    func documentReviewVC(edit document: Document, controller: DocumentReviewVC)
    func documentReviewVC(_ share: Document, shareAs: DocumentReviewVC.ShareOptions, controller: DocumentReviewVC)
}

class DocumentReviewVC: DocumentScannerViewController {
    
    enum ShareOptions {
        case pdf
        case jpg
    }
    
    private lazy var documentPreviewControls: DocumentPreviewControls = {
        let controls = DocumentPreviewControls()
        controls.onEditTap = didTapEdit
        controls.onPDFTap = didTapPreviewAsPDF
        controls.onShareTap = didTapShare
        controls.translatesAutoresizingMaskIntoConstraints = false
        return controls
    }()
    
    weak var delegate: DocumentReviewVCDelegate?
    var document: Document?
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var headerLabel: UILabel!
    
    @IBOutlet private weak var footerContainerView: UIView!
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var documentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _setupView()
        _setupFooterView()
    }
    
    private func _setupView() {
        guard  let document = document else {
            fatalError("ERROR: document is not set")
        }
        navigationController?.navigationBar.isHidden = true
        headerLabel.configure(with: UIFont.font(.avenirMedium, style: .title3))
        headerLabel.text = document.name
        documentImageView.hero.id = document.id.uuidString
        documentImageView.image = document.pages.first?.editedImage
    }
    
    private func _setupFooterView() {
        footerView.addSubview(documentPreviewControls)
        documentPreviewControls.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        
        footerContainerView?.hero.id = Constants.HeroIdentifiers.footerIdentifier
        
    }
    
    @IBAction private func didTaBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func didTapPreviewAsPDF(_ sender: FooterButton) {
        
    }
    
    private func didTapEdit(_ sender: FooterButton) {
        delegate?.documentReviewVC(edit: document!, controller: self)
    }
    
    private func didTapShare(_ sender: FooterButton) {
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
