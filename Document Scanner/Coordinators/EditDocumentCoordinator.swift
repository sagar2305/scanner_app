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
    var isNewDocument: Bool
    // document capturing mode images is passed for editing
    var images: [UIImage]?
    
    var imageSource: ImageSource?
    var quad: Quadrilateral?
    var delegate: EditDocumentCoordinatorDelegate?
    
    init(_ controller: DocumentScannerNavigationController,
         edit images: [UIImage],
         quad: Quadrilateral? = nil,
         imageSource: ImageSource) {
        navigationController = controller
        self.images = images
        self.quad = quad
        self.imageSource = imageSource
        self.isNewDocument = true
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
        self.isNewDocument = false
    }
    
    func start() {
        editImageVC = EditImageVC()
        editImageVC!.imageEditingMode = isNewDocument ? .basic : .correction
        if isNewDocument {
            editImageVC!.imagesToEdit = images
            editImageVC!.quad = quad
        } else {
            editImageVC!.pages = document?.pages
        }
        editImageVC!.delegate = self
        editImageVC.dateSource = self
        navigationController.pushViewController(editImageVC!, animated: true)
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

extension EditDocumentCoordinator: EditImageVCDataSource { }
