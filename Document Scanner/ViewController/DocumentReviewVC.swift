//
//  DocumentReviewVC.swift
//  Document Scanner
//
//  Created by Sandesh on 17/03/21.
//

import UIKit
import SnapKit
import PMAlertController


protocol DocumentReviewVCDelegate: class {
    func documentReviewVC(edit document: Document, controller: DocumentReviewVC)
    func documentReviewVC(_ share: Document, shareAs: DocumentReviewVC.ShareOptions, controller: DocumentReviewVC)
    func documentReviewVC(exit controller: DocumentReviewVC)
    func documentReviewVC(delete document: Document, controller: DocumentReviewVC)
    func documentReviewVC(rename document: Document, name: String
    )
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
        controls.onDeleteTap = didTapDelete
        controls.translatesAutoresizingMaskIntoConstraints = false
        return controls
    }()
    
    weak var delegate: DocumentReviewVCDelegate?
    var document: Document?
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var renameButton: UIButton!
    
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
        headerView.hero.id = Constants.HeroIdentifiers.headerIdentifier
        headerLabel.configure(with: UIFont.font(.avenirRegular, style: .body))
        headerLabel.text = document.name
        documentImageView.hero.id = document.id.uuidString
        documentImageView.image = document.pages.first?.editedImage
        renameButton.titleLabel?.configure(with: UIFont.font(.avenirMedium, style: .callout))
    }
    
    private func _setupFooterView() {
        footerView.addSubview(documentPreviewControls)
        documentPreviewControls.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        
        footerContainerView?.hero.id = Constants.HeroIdentifiers.footerIdentifier
        
    }
    
    private func _presentAlertForDocumentName() {
        let alertVC = PMAlertController(title: "Enter Name", description: nil, image: nil, style: .alert)
        alertVC.alertTitle.textColor = .primary
        
        alertVC.addTextField { (textField) in
                    textField?.placeholder = "Document Name"
                }
        
        alertVC.alertActionStackView.axis = .horizontal
        let doneAction = PMAlertAction(title: "Done", style: .default) {
            let textField = alertVC.textFields[0]
            guard let documentName = textField.text,
                  !documentName.isEmpty else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                return
            }
            self.delegate?.documentReviewVC(rename: self.document!, name: documentName)
            self.headerLabel.text = documentName
        }
        doneAction.setTitleColor(.primary, for: .normal)
        alertVC.addAction(doneAction)
        
        let cancelAction = PMAlertAction(title: "Cancel", style: .cancel) {  }
        alertVC.addAction(cancelAction)
        alertVC.gravityDismissAnimation = false

        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    @IBAction private func didTaBackButton(_ sender: UIButton) {
        delegate?.documentReviewVC(exit: self)
    }
    
    @IBAction func didTapRenameButton(_ sender: UIButton) {
        _presentAlertForDocumentName()
    }
    
    private func didTapPreviewAsPDF(_ sender: FooterButton) {
        
    }
    
    private func didTapEdit(_ sender: FooterButton) {
        delegate?.documentReviewVC(edit: document!, controller: self)
    }
    
    private func didTapDelete(_ sender: FooterButton) {
        guard let document = document else {
            fatalError("ERROR: No document is set")
        }
        delegate?.documentReviewVC(delete: document, controller: self)
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
