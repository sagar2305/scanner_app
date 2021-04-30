//
//  PickDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit
import NVActivityIndicatorView
import WeScan

protocol PickerDocumentCoordinatorDelegate {
    func didFinishedPickingImage(_ coordinator: PickDocumentCoordinator)
    func didCancelPickingImage(_ coordinator: PickDocumentCoordinator)
}

class PickDocumentCoordinator: NSObject, Coordinator {
    var rootViewController: UIViewController {
        return navigationController
    }

    var childCoordinators: [Coordinator] = []
    var delegate: PickerDocumentCoordinatorDelegate?
    var navigationController: DocumentScannerNavigationController
    var correctionVC: CorrectionVC!
    private var isCorrectionVCPresented = false

    func start() {
       _pickDocument()
    }
    
    init(_ rootViewController: DocumentScannerNavigationController) {
        navigationController = rootViewController
    }
    
    private func _pickDocument() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        navigationController.present(imagePickerVC, animated: true)
    }
    
    private func presentImageCorrectionViewController(for image: UIImage) {
        correctionVC = CorrectionVC()
        correctionVC.delegate = self
        correctionVC.dataSource = self
        correctionVC.image = image
        print(image.imageOrientation.rawValue)
        switch image.imageOrientation {
        case .up, .down: correctionVC.shouldRotateImage = false
        default: correctionVC.shouldRotateImage = true
        }
        navigationController.pushViewController(correctionVC, animated: true)
        isCorrectionVCPresented = true
    }

}


extension PickDocumentCoordinator: UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if !isCorrectionVCPresented {
        delegate?.didCancelPickingImage(self)
        }
        rootViewController.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard  let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Failed to pick the image from photo library")
        }
        childCoordinators.removeAll { $0 is EditDocumentCoordinator }
        presentImageCorrectionViewController(for: selectedImage)
        picker.dismiss(animated: true)
    }
    
}

extension PickDocumentCoordinator: CorrectionVCDelegate {
    func correctionVC(_ viewController: CorrectionVC, originalImage: UIImage,
                      finalImage: UIImage) {
        if let document = Document(originalImages: [originalImage], editedImages: [finalImage], quadrilaterals: []) {
            document.save()
            navigationController.popViewController(animated: true)
        }
    }
    
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton) {
        delegate?.didCancelPickingImage(self)
    }
    
    func correctionVC(_ viewController: CorrectionVC, edit image: UIImage) {
        let editDocumentCoordinator = EditDocumentCoordinator(navigationController, edit: image)
        editDocumentCoordinator.delegate = self
        childCoordinators.append(editDocumentCoordinator)
        editDocumentCoordinator.start()
    }
    
    func correctionVC(_ viewController: CorrectionVC, didTapRetake button: UIButton) {
        _pickDocument()
    }
}

extension PickDocumentCoordinator: CorrectionVCDataSource {
    func correctionVC(_ viewController: CorrectionVC, titleFor nextPage: UIButton) -> String {
        return "Pick Next"
    }
}

extension PickDocumentCoordinator: EditDocumentCoordinatorDelegate {
    func didFinishEditing(_ image: UIImage, editedImage: UIImage, _ coordinator: EditDocumentCoordinator) {
        correctionVC.update(image: editedImage)
        navigationController.popViewController(animated: true)
    }
    
    func didCancelEditing(_ coordinator: EditDocumentCoordinator) {
        navigationController.popViewController(animated: true)
    }
}
