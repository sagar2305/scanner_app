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
    func didFinishSavingDocument(_ coordinator: EditDocumentCoordinator, document: Document)
    func rescanDocument(_ coordinator: EditDocumentCoordinator)
    func didCancelEditing(_ coordinator: EditDocumentCoordinator)
}
class EditDocumentCoordinator: Coordinator {
    
    enum ImageSource {
        case photo_library
        case camera
    }
    
    //whether creating new document or editing existing one
    enum DocumentStatus {
        case new
        case existing
    }
    
    var navigationController: DocumentScannerNavigationController
    var childCoordinator: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }
    var parentCoordinator: Coordinator!
    var editImageVC: EditImageVC!
    
    //document editing mode a document is passed for editing
    var document: Document?
    var editedImages: [UIImage]?
    var documentEditingStatus: DocumentStatus?
    // document capturing mode images is passed for editing
    var images: [UIImage]?
    
    var imageSource: ImageSource?
    var quad: Quadrilateral?
    var delegate: EditDocumentCoordinatorDelegate?
    
    init(_ controller: DocumentScannerNavigationController, edit images: [UIImage],quad: Quadrilateral? = nil, imageSource: ImageSource) {
        navigationController = controller
        self.images = images
        self.quad = quad
        self.imageSource = imageSource
    }
    
    init(_ controller: DocumentScannerNavigationController, edit document: Document) {
        navigationController = controller
        self.document = document
        //extract images
        var originalImages: [UIImage] = []
        var lastEditedImages: [UIImage] = []
        document.pages.forEach { page in
            if let originalImage =  page.originalImage, let editedImage = page.editedImage {
                originalImages.append(originalImage)
                lastEditedImages.append(editedImage)
            }
        }
        
        images = originalImages
        editedImages = lastEditedImages
    }
    
    func start() {
        editImageVC = EditImageVC()
        editImageVC!.imageEditingMode = _getInitialEditingMode()
        if _getInitialEditingMode() == .basic {
            editImageVC!.imagesToEdit = images
            editImageVC!.quad = quad
        } else {
            editImageVC!.pages = document?.pages
        }
        editImageVC!.delegate = self
        editImageVC.dateSource = self
        navigationController.pushViewController(editImageVC!, animated: true)
    }
    
    private func _getInitialEditingMode() -> EditImageVC.ImageEditingMode {
        guard let documentStatus = documentEditingStatus else {
            fatalError("ERROR: Document status is not set")
        }
        switch documentStatus {
        case .new: return .basic
        case .existing: return .correction
        }
    }
}


extension EditDocumentCoordinator: EditImageVCDelegate {
    func finishedEditing(_ pages: [Page], controller: EditImageVC) {
        guard let document = document else {
            fatalError("ERROR: Document not available")
        }
        
        document.pages = pages
        document.update()
        delegate?.didFinishSavingDocument(self, document: document)
    }
    
  
    func cancelImageEditing(_controller: EditImageVC) {
        delegate?.didCancelEditing(self)
    }
    
    func rescanImage(_ controller: EditImageVC) {
        delegate?.rescanDocument(self)
    }
    
    func finishedImageEditing(_ finalImage: [UIImage], originalImage: [UIImage], documentName: String, controller: EditImageVC) {
        var quadPoints = [CGPoint]()
       
        
        let activityIndicator = NVActivityIndicatorView(frame: rootViewController.view.frame,
                                                        type: .ballRotateChase,
                                                        color: UIColor.blue,
                                                        padding: 16)
        activityIndicator.startAnimating()
        
        if let quad = controller.quad  {
            quadPoints = []
            quadPoints.append(quad.topLeft)
            quadPoints.append(quad.topRight)
            quadPoints.append(quad.bottomLeft)
            quadPoints.append(quad.bottomRight)
        }
        
        if let document = Document(documentName, originalImages: originalImage, editedImages: finalImage, quadrilaterals: []) {
            document.save()
            delegate?.didFinishSavingDocument(self, document: document)
        } else {
            //TODO: - Handle the failure rather then crashing the app
            fatalError("ERROR: Failed to save document")
        }
    }
}

extension EditDocumentCoordinator: EditImageVCDataSource {
    var documentStatus: DocumentStatus {
        guard  let documentStatus = documentEditingStatus else {
            fatalError("ERROR: Document status is not set")
        }
        return documentStatus
    }
    

}
