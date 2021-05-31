//
//  ScanDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 05/03/21.
//

import UIKit
import WeScan
import NVActivityIndicatorView
import PMAlertController

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
    private var currentDocumentImages = [UIImage]()
    private var currentDocumentImagesQuads = [Quadrilateral?]()

    
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
    func scannerVC(_ controller: ScannerVC, finishedScanning images: [NewDocumentImageViewController]) {
        correctionVC = CorrectionVC()
        correctionVC.delegate = self
        correctionVC.dataSource = self
        correctionVC.pageControllerItems = images
        navigationController.pushViewController(correctionVC, animated: true)
        isCorrectionVCPresented = true
    }
    
    func cancelScanning(_ controller: ScannerVC) {
        navigationController.popViewController(animated: true)
    }
}

extension ScanDocumentCoordinator: CorrectionVCDelegate {
    func correctionVC(_ viewController: CorrectionVC, didFinishCorrectingImages imageVCs: [NewDocumentImageViewController]) {
        NVActivityIndicatorView.start()
        imageVCs.forEach { $0.cropImage() }
        let originalImages = imageVCs.map { $0.originalImage }
        let editedImages = imageVCs.map { $0.finalImage }
    
        if let document = Document(originalImages: originalImages, editedImages: editedImages) {
            document.save()
            NVActivityIndicatorView.stop()
            navigationController.popToRootViewController(animated: true)
        } else {
            let alertVC = PMAlertController(title: "Something went wrong",
                                            description: "Unable to save generate your document, please try again",
                                            image: nil,
                                            style: .alert)
            alertVC.alertTitle.textColor = .primary
            let okAction = PMAlertAction(title: "OK", style: .default) {
                self.navigationController.popViewController(animated: true)
            }
            okAction.setTitleColor(.primary, for: .normal)
            alertVC.addAction(okAction)
            alertVC.gravityDismissAnimation = false
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton) {
        delegate?.didCancelScanningDocument(self)
    }
    
    func correctionVC(_ viewController: CorrectionVC, edit image: UIImage) {
        let updatedOrientationImage = image.removeRotation()
        let editDocumentCoordinator = EditDocumentCoordinator(navigationController, edit: updatedOrientationImage)
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
    func didFinishEditing(_ image: UIImage, editedImage: UIImage, _ coordinator: EditDocumentCoordinator, isRotated: Bool) {
        correctionVC.updateEdited(image: editedImage, isRotated: isRotated)
        navigationController.popViewController(animated: true)
    }
    
    func didCancelEditing(_ coordinator: EditDocumentCoordinator) {
        navigationController.popViewController(animated: true)
    }
}
