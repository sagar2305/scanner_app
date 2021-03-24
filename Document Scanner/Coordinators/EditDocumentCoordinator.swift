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
    }
    
    func start() {
        editImageVC = EditImageVC()
        editImageVC!.imageEditingMode = _getInitialEditingMode()
        editImageVC!.imagesToEdit = images
        editImageVC!.quad = quad
        editImageVC!.delegate = self
        editImageVC.dateSource = self
        navigationController.pushViewController(editImageVC!, animated: true)
    }
    
    private func _getInitialEditingMode() -> EditImageVC.ImageEditingMode {
        if imageSource == nil  {
            //editing document to
            return .correction
        } else {
            return .basic
        }
    }
}


extension EditDocumentCoordinator: EditImageVCDelegate {
  
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
        } else {
            fatalError("ERROR: Failed to save document")
        }
    }
}

extension EditDocumentCoordinator: EditImageVCDataSource {

}
