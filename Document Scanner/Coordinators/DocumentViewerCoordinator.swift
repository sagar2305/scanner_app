//
//  DocumentViewerCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 25/03/21.
//

import UIKit
import QuickLook

protocol DocumentViewerCoordinatorDelegate: AnyObject {
    func exit(_ coordinator: DocumentViewerCoordinator)
}

class DocumentViewerCoordinator: NSObject, Coordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    var childCoordinators: [Coordinator] = []
    var pageItems = [DocumentPageViewController]()
    let navigationController: DocumentScannerNavigationController
    var documentReviewVC: DocumentReviewVC!
    var document: Document
    var pageBeingEdited: Page?
    
    init(_ navigationController: DocumentScannerNavigationController, document: Document) {
        self.navigationController = navigationController
        self.document = document
        pageItems = document.pages.map { DocumentPageViewController($0) }
    }
    
    func start() {
        let documentReviewVC = DocumentReviewVC()
        documentReviewVC.document = document
        documentReviewVC.delegate = self
        documentReviewVC.pageControllerItems = pageItems
        self.documentReviewVC = documentReviewVC
        navigationController.pushViewController(documentReviewVC, animated: true)
    }
}

extension DocumentViewerCoordinator: DocumentReviewVCDelegate {
    func documentReviewVC(viewDidAppear controller: DocumentScannerViewController) {
        AnalyticsHelper.shared.logEvent(.userOpenedDocument, properties: [
                                            .documentID: document.id.uuidString,
                                            .numberOfDocumentPages: document.pages.count
         ])
    }
    
    func documentReviewVC(rename document: Document, name: String) {
        document.rename(new: name)
        AnalyticsHelper.shared.logEvent(.renamedDocument, properties: [
                                            .documentID: document.id.uuidString,
         ])
    }
    
    func documentReviewVC(edit page: Page, controller: DocumentReviewVC) {
        pageBeingEdited = page
        let editDocumentCoordinator = EditDocumentCoordinator(navigationController,
                                                              edit: pageBeingEdited!.editedImage!,
                                                              originalImage: pageBeingEdited!.originalImage!)
        editDocumentCoordinator.delegate = self
        childCoordinators.append(editDocumentCoordinator)
        editDocumentCoordinator.start()
    }
    
    func documentReviewVC(markup page: Page, controller: DocumentReviewVC) {
        pageBeingEdited = page
        let quickLookPreviewController = QLPreviewController()
        quickLookPreviewController.dataSource = self
        quickLookPreviewController.delegate = self
        controller.present(quickLookPreviewController, animated: true)
    }
    
    func documentReviewVC(_ share: Document, shareAs: DocumentReviewVC.ShareOptions, controller: DocumentReviewVC) {
        var documentToShare: [Any]
        
        switch shareAs {
       
        case .pdf:
            let pdfData = PDFGeneratorHelper.generatePDF(for: document)
            documentToShare = [pdfData as Any]
        case .jpg:
            guard let imageToShare = document.pages.first?.editedImage else {
                fatalError("ERROR: failed to find edited image for document")
            }
            documentToShare = [imageToShare]
        }
        let activityVC = UIActivityViewController(activityItems: documentToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, .airDrop]
        activityVC.completionWithItemsHandler = { activity, completed, item, error in
            if error != nil || !completed {
                AnalyticsHelper.shared.logEvent(.documentSharingFailed, properties: [
                    .documentID: share.id.uuidString
                ])
            }
            AnalyticsHelper.shared.logEvent(.userSharedDocument, properties: [
                .documentID: share.id.uuidString
            ])
        }
        navigationController.present(activityVC, animated: true)
    }
    
    func documentReviewVC(exit controller: DocumentReviewVC) {
        navigationController.popToRootViewController(animated: true)
    }
    
    func documentReviewVC(delete document: Document, controller: DocumentReviewVC) {
        document.delete()
        AnalyticsHelper.shared.logEvent(.userDeletedDocument, properties: [
                                            .documentID: document.id.uuidString,
         ])
        navigationController.popToRootViewController(animated: true)
    }
    
    func documentReviewVC(controller: DocumentReviewVC, markup document: Document, startIndex: Int) {
        let quickLookPreviewController = QLPreviewController()
        quickLookPreviewController.dataSource = self
        quickLookPreviewController.delegate = self
        quickLookPreviewController.currentPreviewItemIndex = startIndex
        controller.present(quickLookPreviewController, animated: true)
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

extension DocumentViewerCoordinator: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let pageBeingEdited = pageBeingEdited else { fatalError("Page not set")}
        return pageBeingEdited
    }
}

extension DocumentViewerCoordinator: QLPreviewControllerDelegate {
    
    @available(iOS 13.0, *)
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .updateContents
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        guard  let page = previewItem as? Page else {
            print("NOT PAGE")
            return
        }
        
//        let pageControllerItem = pageItems.first { $0.page.id == page.id }
//        documentReviewVC.pageControllerItems = pageItems
        
    }
}
