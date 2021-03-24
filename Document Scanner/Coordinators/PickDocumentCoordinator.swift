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
    var childCoordinator: [Coordinator] = []
    
    var delegate: PickerDocumentCoordinatorDelegate?
    var navigationController: DocumentScannerNavigationController
    var editImageVC: EditImageVC?
    
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
        let editDocumentCoordinator = EditDocumentCoordinator(navigationController, edit: [image], imageSource: .photo_library)
        editDocumentCoordinator.delegate = self
        editDocumentCoordinator.images = [image]
        childCoordinator.append(editDocumentCoordinator)
        editDocumentCoordinator.start()
    }

}


extension PickDocumentCoordinator: UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.didCancelPickingImage(self)
        rootViewController.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard  let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Failed to pick the image from photo library")
        }
        childCoordinator.removeAll { $0 is EditDocumentCoordinator }
        presentImageCorrectionViewController(for: selectedImage)
        picker.dismiss(animated: true)
    }
    
}

extension PickDocumentCoordinator: EditDocumentCoordinatorDelegate {
    func didFinishSavingDocument(_ coordinator: EditDocumentCoordinator, document: Document) {
        delegate?.didCancelPickingImage(self)
    }
    
    func rescanDocument(_ coordinator: EditDocumentCoordinator) {
        _pickDocument()
    }
    
    func didCancelEditing(_ coordinator: EditDocumentCoordinator) {
        delegate?.didCancelPickingImage(self)
    }
    
    
    
    
}
