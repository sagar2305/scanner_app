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
    var correctionVC: CorrectionVC!
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
        correctionVC = CorrectionVC()
        correctionVC.delegate = self
        correctionVC.quad = quad
        correctionVC.image = image
        navigationController.pushViewController(correctionVC, animated: true)
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

extension ScanDocumentCoordinator: CorrectionVCDelegate {
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton) {
        delegate?.didCancelScanningDocument(self)
    }
    
    func correctionVC(_ viewController: CorrectionVC, final image: UIImage) {
        //TODO: - go editing
    }
    
    func correctionVC(_ viewController: CorrectionVC, didTapRetake button: UIButton) {
        navigationController.popViewController(animated: true)
    }    
}
