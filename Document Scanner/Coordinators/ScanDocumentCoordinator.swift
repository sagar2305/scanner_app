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
    
    private var isCorrectionVCPresented = false
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
        correctionVC.dataSource = self
        correctionVC.quad = quad
        correctionVC.image = image
        correctionVC.shouldRotateImage = true
        navigationController.pushViewController(correctionVC, animated: true)
        isCorrectionVCPresented = true
    }
}

extension ScanDocumentCoordinator: CorrectionVCDelegate {
    func correctionVC(_ viewController: CorrectionVC, originalImage: UIImage, finalImage: UIImage) {
        if let document = Document(originalImages: [originalImage], editedImages: [finalImage], quadrilaterals: []) {
            document.save()
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton) {
        delegate?.didCancelScanningDocument(self)
    }
    
    func correctionVC(_ viewController: CorrectionVC, edit image: UIImage) {
        let editDocumentCoordinator = EditDocumentCoordinator(navigationController, edit: image)
        editDocumentCoordinator.delegate = self
        childCoordinators.append(editDocumentCoordinator)
        editDocumentCoordinator.start()
    }
    
    func correctionVC(_ viewController: CorrectionVC, didTapRetake button: UIButton) {
        navigationController.popViewController(animated: true)
    }    
}

extension ScanDocumentCoordinator: CorrectionVCDataSource {
    func correctionVC(_ viewController: CorrectionVC, titleFor nextPage: UIButton) -> String {
        return "Scan Next"
    }
}

extension ScanDocumentCoordinator: EditDocumentCoordinatorDelegate {
    func didFinishEditing(_ image: UIImage, editedImage: UIImage, _ coordinator: EditDocumentCoordinator) {
        correctionVC.update(image: editedImage)
        navigationController.popViewController(animated: true)
    }
    
    func didCancelEditing(_ coordinator: EditDocumentCoordinator) {
        navigationController.popViewController(animated: true)
    }
}
