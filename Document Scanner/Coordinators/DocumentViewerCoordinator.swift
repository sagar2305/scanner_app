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
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: DocumentScannerNavigationController
    var documentReviewVC: DocumentScannerViewController!
    var document: Document
    var pageBeingEdited: Page?
    
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
    func documentReviewVC(rename document: Document, name: String) {
        document.rename(new: name)
    }
    
    //TODO: - Replace document with page as we update a page at a time
    func documentReviewVC(edit document: Document, controller: DocumentReviewVC) {
        pageBeingEdited = document.pages.first!
        let editDocumentCoordinator = EditDocumentCoordinator(navigationController,
                                                              edit: pageBeingEdited!.editedImage!,
                                                              originalImage: pageBeingEdited!.originalImage!)
        editDocumentCoordinator.delegate = self
        childCoordinators.append(editDocumentCoordinator)
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
    
    func documentReviewVC(exit controller: DocumentReviewVC) {
        navigationController.popViewController(animated: true)
    }
    
    func documentReviewVC(delete document: Document, controller: DocumentReviewVC) {
        document.delete()
        navigationController.popViewController(animated: true)
    }
    
}

extension DocumentViewerCoordinator: EditDocumentCoordinatorDelegate {
    func didFinishEditing(_ image: UIImage, editedImage: UIImage, _ coordinator: EditDocumentCoordinator, isRotated: Bool) {
        guard let  pageBeingEdited = pageBeingEdited else {
            fatalError("ERROR: no page is set for editing")
        }
        if pageBeingEdited.saveEditedImage(editedImage) {
            document.update()
            navigationController.popViewController(animated: true)
        }
    }
    
    
    func didCancelEditing(_ coordinator: EditDocumentCoordinator) {
        navigationController.popViewController(animated: true)
    }
}
