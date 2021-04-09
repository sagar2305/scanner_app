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
    func didCancelScanningDocument(_ coordinator: ScanDocumentCoordinator)
}

class ScanDocumentCoordinator: Coordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    var childCoordinators: [Coordinator] = []
    var navigationController: DocumentScannerNavigationController
    var editImageVC: EditImageVC!
    weak var delegate: ScanDocumentCoordinatorDelegate?
    
    init(_ controller: DocumentScannerNavigationController) {
        self.navigationController = controller
    }
    
    func start() {
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
        let editDocumentCoordinator = EditDocumentCoordinator(navigationController, edit: [image],quad: quad, imageSource: .camera)
        editDocumentCoordinator.delegate = self
        childCoordinators.append(editDocumentCoordinator)
        editDocumentCoordinator.start()
    }
    
}

extension ScanDocumentCoordinator: EditDocumentCoordinatorDelegate {
    func didFinishSavingDocument(_ coordinator: EditDocumentCoordinator, document: Document) {
        delegate?.didFinishScanningDocument(self)
    }
    
    func rescanDocument(_ coordinator: EditDocumentCoordinator) {
        navigationController.popViewController(animated: true)
        childCoordinators.removeAll { $0 is EditDocumentCoordinator }
    }
    
    func didCancelEditing(_ coordinator: EditDocumentCoordinator) {
        delegate?.didCancelScanningDocument(self)
    }
    
    
}
