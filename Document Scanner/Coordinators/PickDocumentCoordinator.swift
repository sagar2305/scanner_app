//
//  PickDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit
import NVActivityIndicatorView
import WeScan
import QBImagePickerController

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
    private var currentDocumentImages = [UIImage]()

    func start() {
       _pickDocument()
    }
    
    init(_ rootViewController: DocumentScannerNavigationController) {
        navigationController = rootViewController
    }
    
    private func _pickDocument() {
//        let imagePickerVC = UIImagePickerController()
//        imagePickerVC.sourceType = .photoLibrary
//        imagePickerVC.delegate = self
//        navigationController.present(imagePickerVC, animated: true)
        
        let qbImagePicker = QBImagePickerController()
        qbImagePicker.allowsMultipleSelection = true
        qbImagePicker.maximumNumberOfSelection = 8
        qbImagePicker.showsNumberOfSelectedAssets = true
        qbImagePicker.delegate = self
        qbImagePicker.assetCollectionSubtypes = [PHAssetCollectionSubtype.albumCloudShared,
                                                 PHAssetCollectionSubtype.albumMyPhotoStream,
                                                 ]
        navigationController.present(qbImagePicker, animated: true)
    }
    
    private func presentImageCorrectionViewController(for image: UIImage) {
        currentDocumentImages.append(image)
        correctionVC = CorrectionVC()
        correctionVC.delegate = self
        correctionVC.dataSource = self
        //    correctionVC.images = currentDocumentImages
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
    func correctionVC(_ viewController: CorrectionVC, originalImages: [UIImage], finalImages: [UIImage]) {
        if let document = Document(originalImages: originalImages, editedImages: finalImages, quadrilaterals: []) {
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
    func didFinishEditing(_ image: UIImage, editedImage: UIImage, _ coordinator: EditDocumentCoordinator, isRotated: Bool) {
        correctionVC.updateEdited(image: editedImage, isRotated: isRotated)
        navigationController.popViewController(animated: true)
    }
    
    func didCancelEditing(_ coordinator: EditDocumentCoordinator) {
        navigationController.popViewController(animated: true)
    }
}

extension PickDocumentCoordinator: QBImagePickerControllerDelegate {
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        print(assets.count)
        //TODO: - present correction
        
        
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        imagePickerController.dismiss(animated: true)
    }
}
