//
//  PickDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit

protocol PickerDocumentCoordinatorDelegate {
    func didFinishedPickingImage(_ coordinator: PickDocumentCoordinator)
    func didCancelPickingImage(_ coordinator: PickDocumentCoordinator)
}

class PickDocumentCoordinator: NSObject, Coordinator {
    var rootViewController: UIViewController
    var childCoordinator: [Coordinator] = []
    
    var delegate: PickerDocumentCoordinatorDelegate?
    
    func start() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
    }
    
    init(_ rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    /// presents user option to crop / rotate selected image
    private func presentImageCorrectionViewController(for image: UIImage) {

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
        presentImageCorrectionViewController(for: selectedImage)
    }
    
}
