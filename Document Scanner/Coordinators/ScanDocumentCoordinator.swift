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
import VisionKit

protocol ScanDocumentCoordinatorDelegate: AnyObject {
    func didFinishScanningDocument(_ coordinator: ScanDocumentCoordinator)
    func didCancelScanningDocument(_ coordinator: ScanDocumentCoordinator)
}

class ScanDocumentCoordinator: NSObject, Coordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    private var isCorrectionVCPresented = false
    var childCoordinators: [Coordinator] = []
    var navigationController: DocumentScannerNavigationController
    var correctionVC: CorrectionVC!
    var existingDocument: Document?
    weak var delegate: ScanDocumentCoordinatorDelegate?
    private var currentDocumentImages = [UIImage]()
    private var currentDocumentImagesQuads = [Quadrilateral?]()

    
    init(_ controller: DocumentScannerNavigationController, existing document: Document? = nil) {
        self.navigationController = controller
        existingDocument = document
    }
    
    func start() {
        if #available(iOS 13, *) {
            guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else { return }
            let scannerViewController = VNDocumentCameraViewController()
            scannerViewController.delegate = self
            navigationController.present(scannerViewController, animated: true)
        } else {
            let scanDocumentVC = ScannerVC()
            scanDocumentVC.delegate = self
            navigationController.pushViewController(scanDocumentVC, animated: true)
        }
    }
}


extension ScanDocumentCoordinator: ScannerVCDelegate {
    func scannerVC(_ controller: ScannerVC, finishedScanning images: [NewDocumentImageViewController]) {
        
        AnalyticsHelper.shared.logEvent(.userScannedDocument , properties: [
            .numberOfDocumentPages: images.count
        ])
        
        correctionVC = CorrectionVC()
        correctionVC.delegate =  self
        correctionVC.dataSource = self
        correctionVC.pageControllerItems = images
        navigationController.pushViewController(correctionVC, animated: true)
        isCorrectionVCPresented = true
    }
    
    func cancelScanning(_ controller: ScannerVC) {
        navigationController.popViewController(animated: true)
    }
    
    private func view(_ document: Document) {
        let documentViewerCoordinator = DocumentViewerCoordinator(navigationController, document: document)
        childCoordinators.append(documentViewerCoordinator)
        documentViewerCoordinator.start()
    }
}

extension ScanDocumentCoordinator: CorrectionVCDelegate {
    func correctionVC(_ viewController: CorrectionVC, didFinishCorrectingImages imageVCs: [NewDocumentImageViewController]) {
        NVActivityIndicatorView.start()
        imageVCs.forEach { $0.cropImage() }
        let originalImages = imageVCs.map { $0.originalImage }
        let editedImages = imageVCs.map { $0.finalImage }
        _saveDocument(originalImages: originalImages, editedImages: editedImages, controller: viewController)
        
    }
    
    private func _saveDocument(originalImages: [UIImage], editedImages: [UIImage], controller: UIViewController) {
        if let document = existingDocument {
            DocumentHelper.shared.addPages(to: document, originalImages: originalImages, editedImages: editedImages)
            view(document)
            NVActivityIndicatorView.stop()
        } else {
            if let document = DocumentHelper.shared.generateDocument(originalImages: originalImages, editedImages: editedImages) {
                view(document)
                NVActivityIndicatorView.stop()
            } else {
                let alertVC = PMAlertController(title: "Something went wrong".localized,
                                                description: "Unable to save generate your document, please try again".localized,
                                                image: nil,
                                                style: .alert)
                alertVC.alertTitle.textColor = .primary
                let okAction = PMAlertAction(title: "OK".localized, style: .default) {
                    self.navigationController.popViewController(animated: true)
                }
                okAction.setTitleColor(.primary, for: .normal)
                alertVC.addAction(okAction)
                alertVC.gravityDismissAnimation = false
                controller.present(alertVC, animated: true, completion: nil)
                NVActivityIndicatorView.stop()
            }
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

@available(iOS 13, *)
extension ScanDocumentCoordinator: VNDocumentCameraViewControllerDelegate {
    internal func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var images = [UIImage]()
        
        for index in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: index)
            images.append(image)
        }
        
        self._saveDocument(originalImages: images, editedImages: images, controller: controller)
        controller.dismiss(animated: true)
    }
    
    internal func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
    }
    
    internal func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
      controller.dismiss(animated: true)
    }
}
