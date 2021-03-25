//
//  DocumentViewerCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 25/03/21.
//

import UIKit

class DocumentViewerCoordinator: Coordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    var childCoordinator: [Coordinator] = []
    
    let navigationController: DocumentScannerNavigationController
    var documentReviewVC: DocumentScannerViewController!
    var document: Document
    
    init(_ navigationController: DocumentScannerNavigationController, document: Document) {
        self.navigationController = navigationController
        self.document = document
    }
    
    func start() {
        let documentReviewVC = DocumentReviewVC()
        documentReviewVC.document = document
        documentReviewVC.delegate = self
        self.documentReviewVC = documentReviewVC
        navigationController.pushViewController(documentReviewVC, animated: true)
    }
}

extension DocumentViewerCoordinator: DocumentReviewVCDelegate {
    func documentReviewVC(edit document: Document, controller: DocumentReviewVC) {
        let editDocumentCoordinator = EditDocumentCoordinator(navigationController, edit: document)
        editDocumentCoordinator.delegate = self
        editDocumentCoordinator.documentEditingStatus = .existing
        childCoordinator.append(editDocumentCoordinator)
        editDocumentCoordinator.start()
    }
    
    
    func documentReviewVC(_ share: Document, shareAs: DocumentReviewVC.ShareOptions, controller: DocumentReviewVC) {
        var documentToShare: [Any]
        
        switch shareAs {
       
        case .pdf:
            guard  let pdfPath = document.convertToPDF() else {
                fatalError("ERROR: failed to generate PDF for document")
            }
            let pdfData = NSData(contentsOfFile: pdfPath)
            documentToShare = [pdfData as Any]
        case .jpg:
            guard let imageToShare = document.pages.first?.editedImage else {
                fatalError("ERROR: failed to find edited image for document")
            }
            documentToShare = [imageToShare]
        }
        let activityVC = UIActivityViewController(activityItems: documentToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, .airDrop]
        activityVC.completionWithItemsHandler = { activity, completed, item, error in }
        navigationController.present(activityVC, animated: true)
    }
    
}

extension DocumentViewerCoordinator: EditDocumentCoordinatorDelegate {
    func didFinishSavingDocument(_ coordinator: EditDocumentCoordinator, document: Document) {
        (documentReviewVC as! DocumentReviewVC).document = document
        navigationController.popViewController(animated: true)
    }
    
    func rescanDocument(_ coordinator: EditDocumentCoordinator) {
        
    }
    
    func didCancelEditing(_ coordinator: EditDocumentCoordinator) {
        navigationController.popViewController(animated: true)
    }
}
