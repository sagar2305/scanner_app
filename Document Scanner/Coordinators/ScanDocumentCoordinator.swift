//
//  ScanDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 05/03/21.
//

import UIKit
import WeScan
import NVActivityIndicatorView

protocol ScanDocumentCoordinatorDelegate: class {
    func didFinishScanningDocument(_ coordinator: ScanDocumentCoordinator)
}

class ScanDocumentCoordinator: Coordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    var childCoordinator: [Coordinator] = []
    var navigationController: UINavigationController
    var editImageVC: EditImageVC!
    weak var delegate: ScanDocumentCoordinatorDelegate?
    
    init(_ controller: UINavigationController) {
        self.navigationController = controller
    }
    
    func start() {
        let scanDocumentVC = ScannerVC()
        scanDocumentVC.delegate = self
        navigationController.pushViewController(scanDocumentVC, animated: true)
    }
    
    private func _startScanning() {
        let scanDocumentVC = ScannerVC()
        scanDocumentVC.delegate = self
        navigationController.pushViewController(scanDocumentVC, animated: true)
    }
}


extension ScanDocumentCoordinator: ScannerVCDelegate {
    func cancelScanning(_ controller: ScannerVC) {
        navigationController.popViewController(animated: true)
    }
    
    func didScannedDocumentImage(_ image: UIImage,quad: Quadrilateral?, controller: ScannerVC) {
        editImageVC = EditImageVC()
        editImageVC.imageToEdit = image
        editImageVC.imageEditingMode = .basic
        editImageVC.quad = quad
        editImageVC.imageSource = .camera
        editImageVC.delegate = self
        navigationController.pushViewController(editImageVC, animated: true)
    }
    
}

extension ScanDocumentCoordinator: EditImageVCDelegate {
    func cancelImageEditing(_controller: EditImageVC) {
        delegate?.didFinishScanningDocument(self)
    }
    
    func filterImage(_ image: UIImage, controller: EditImageVC) {
       
    }
    
    func rescanImage(_ controller: EditImageVC) {
        navigationController.popViewController(animated: true)
    }
    
    func finishedImageEditing(_ finalImage: UIImage, originalImage: UIImage, documentName: String, controller: EditImageVC) {
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
        
        let document = Document(documentName,
                                originalImage: originalImage,
                                editedImage: finalImage,
                                quadrilateral: quadPoints)
        
        if document.saveOriginalImage(originalImage) && document.saveEditedImage(finalImage) {
            document.save()
            activityIndicator.stopAnimating()
            delegate?.didFinishScanningDocument(self)
        }
    }
    
    
}
