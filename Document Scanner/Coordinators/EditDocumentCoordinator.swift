//
//  EditDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 17/03/21.
//

import UIKit
import WeScan

import NVActivityIndicatorView

protocol EditDocumentCoordinatorDelegate: class {
    func didFinishEditing(_ image: UIImage, editedImage: UIImage, _ coordinator: EditDocumentCoordinator, isRotated: Bool)
    func didCancelEditing(_ coordinator: EditDocumentCoordinator)
}
class EditDocumentCoordinator: Coordinator {

    var navigationController: DocumentScannerNavigationController
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }
    var parentCoordinator: Coordinator!
    var editImageVC: EditImageVC!
    
    //document editing mode a document is passed for editing
    var originalImage: UIImage?
    var isNewDocument: Bool
    var imageToEdit: UIImage
    var delegate: EditDocumentCoordinatorDelegate?
    var page: Page?
    var document: Document?
    
    init(_ controller: DocumentScannerNavigationController, edit image: UIImage, originalImage: UIImage? = nil, page: Page? = nil, document: Document? = nil) {
        navigationController = controller
        self.imageToEdit = image
        self.originalImage = originalImage
        self.isNewDocument = originalImage == nil
        self.page = page
        self.document = document
    }
    
    func start() {
        editImageVC = EditImageVC()
        editImageVC!.imageToEdit = imageToEdit
        editImageVC!.delegate = self
        editImageVC.dataSource = self
        navigationController.pushViewController(editImageVC!, animated: true)
    }
}


extension EditDocumentCoordinator: EditImageVCDelegate {
    func viewDidAppear(_ controller: DocumentScannerViewController) {
        AnalyticsHelper.shared.logEvent(.userEditingImage)
    }
    
    
    func finishedImageEditing(_ finalImage: UIImage, controller: EditImageVC, isRotated: Bool) {
        delegate?.didFinishEditing(imageToEdit, editedImage: finalImage, self, isRotated: isRotated)
        AnalyticsHelper.shared.logEvent(.finishedEditingImage)
    }
    
    func cancelImageEditing(_controller: EditImageVC) {
        delegate?.didCancelEditing(self)
        AnalyticsHelper.shared.logEvent(.cancelledEditingImage)
    }
    
    func deletePage(_ controller: EditImageVC) {
        guard let  pageBeingEdited = page, let document = document else {
            let viewControllers: [UIViewController] = self.navigationController.viewControllers
            for aViewController in viewControllers {
                if aViewController is DocumentReviewVC {
                    self.navigationController.popToViewController(aViewController, animated: true)
                }
            }
            return
        }
        if document.pages.count > 1 {
            DocumentHelper.shared.deletePage(pageBeingEdited, of: document)
            let documentViewerCoordinator = DocumentViewerCoordinator(navigationController, document: document)
            childCoordinators.append(documentViewerCoordinator)
            documentViewerCoordinator.start()
        } else {
            DocumentHelper.shared.delete(document: document)
            navigationController.popToRootViewController(animated: true)
        }
        
    }
}

extension EditDocumentCoordinator: EditImageVCDataSource { }
